import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:markdown/markdown.dart' as md;
import 'package:markdown/markdown.dart' show InlineSyntax;
import '../../../../../app/app_router.dart';
import 'thinking_chain_widget.dart';
import '../../../domain/entities/chat_message.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'enhanced_mermaid_renderer.dart';
import 'file_attachment_card.dart';
import 'image_preview_widget.dart';

/// 消息内容渲染组件
///
/// 支持功能：
/// - Markdown语法渲染
/// - 代码块显示
/// - 代码折叠/展开
/// - 行号显示
/// - 复制功能
/// - 多种主题
class MessageContentWidget extends ConsumerStatefulWidget {
  final ChatMessage message;

  const MessageContentWidget({super.key, required this.message});

  @override
  ConsumerState<MessageContentWidget> createState() =>
      _MessageContentWidgetState();
}

class _MessageContentWidgetState extends ConsumerState<MessageContentWidget> {
  // 缓存分离后的内容，减少重复计算
  Map<String, String?>? _cachedSeparatedContent;
  String? _lastProcessedContent;
  MarkdownStyleSheet? _cachedStyleSheet;
  ThemeData? _lastTheme;

  @override
  Widget build(BuildContext context) {
    final generalSettings = ref.watch(generalSettingsProvider);
    final codeBlockSettings = ref.watch(codeBlockSettingsProvider);

    // 仅在内容变化时重新分离思考链与正文
    if (_lastProcessedContent != widget.message.content) {
      _cachedSeparatedContent = _separateThinkingAndContent(
        widget.message.content,
      );
      _lastProcessedContent = widget.message.content;
    }

    final separated = _cachedSeparatedContent!;
    final thinkingContent = separated['thinking'];
    final actualContent = separated['content'] ?? widget.message.content;

    // 如果不启用Markdown渲染，直接返回纯文本
    if (!generalSettings.enableMarkdownRendering) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 思考链显示
          if (thinkingContent != null && !widget.message.isFromUser)
            ThinkingChainWidget(
              content: thinkingContent,
              modelName: widget.message.modelName ?? '',
              isCompleted: true, // UI层面分离时总是完整的
            ),
          // 主要内容
          SelectableText(
            actualContent,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: widget.message.isFromUser
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 思考链显示
        if (thinkingContent != null && !widget.message.isFromUser)
          ThinkingChainWidget(
            content: thinkingContent,
            modelName: widget.message.modelName ?? '',
            isCompleted: true, // UI层面分离时总是完整的
          ),
        // 文件附件显示
        if (widget.message.attachments.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.message.attachments.map((attachment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: FileAttachmentCard(attachment: attachment),
                );
              }).toList(),
            ),
          ),

        // 图片显示 - 卡片式布局
        if (widget.message.imageUrls.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: _buildImageCards(),
          ),
        // 主要内容
        if (actualContent.trim().isNotEmpty)
          _buildContentWithMath(
            context: context,
            content: actualContent,
            styleSheet: _getMarkdownStyleSheet(context),
            codeBlockSettings: codeBlockSettings,
          ),
      ],
    );
  }

  /// 获取缓存的Markdown样式表
  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);

    // 如果主题改变了，重新构建样式表
    if (_cachedStyleSheet == null || _lastTheme != theme) {
      _lastTheme = theme;
      _cachedStyleSheet = _buildMarkdownStyleSheet(context);
    }

    return _cachedStyleSheet!;
  }

  /// 构建Markdown样式表
  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = widget.message.isFromUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return MarkdownStyleSheet(
      p: theme.textTheme.bodyMedium?.copyWith(color: textColor),
      h1: theme.textTheme.headlineMedium?.copyWith(color: textColor),
      h2: theme.textTheme.headlineSmall?.copyWith(color: textColor),
      h3: theme.textTheme.titleLarge?.copyWith(color: textColor),
      h4: theme.textTheme.titleMedium?.copyWith(color: textColor),
      h5: theme.textTheme.titleSmall?.copyWith(color: textColor),
      h6: theme.textTheme.titleSmall?.copyWith(color: textColor),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: textColor.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
      ),
      strong: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      em: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(color: textColor),
    );
  }

  /// 从内容中分离思考链和正文
  Map<String, String?> _separateThinkingAndContent(String content) {
    String? thinkingContent;
    String actualContent = content;

    // 检查是否包含think标签
    if (content.contains('<think>') && content.contains('</think>')) {
      final thinkStart = content.indexOf('<think>');
      final thinkEnd = content.indexOf('</think>');

      if (thinkStart != -1 && thinkEnd != -1 && thinkEnd > thinkStart) {
        // 提取思考链内容（去除标签）
        thinkingContent = content.substring(thinkStart + 7, thinkEnd).trim();

        // 提取正文内容（去除思考链部分）
        final beforeThink = content.substring(0, thinkStart).trim();
        final afterThink = content.substring(thinkEnd + 8).trim();
        actualContent = '$beforeThink $afterThink'.trim();
      }
    }

    return {'thinking': thinkingContent, 'content': actualContent};
  }

  /// 构建图片卡片网格
  Widget _buildImageCards() {
    // 从消息元数据中获取图片文件名和大小信息
    final imageFileNames =
        widget.message.metadata?['imageFileNames'] as List<dynamic>?;
    final imageFileSizes =
        widget.message.metadata?['imageFileSizes'] as List<dynamic>?;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.message.imageUrls.asMap().entries.map((entry) {
        final index = entry.key;
        final imageUrl = entry.value;

        // 获取对应索引的文件名和大小
        String? fileName;
        int? fileSize;

        if (imageFileNames != null && index < imageFileNames.length) {
          fileName = imageFileNames[index] as String?;
        }

        if (imageFileSizes != null && index < imageFileSizes.length) {
          fileSize = imageFileSizes[index] as int?;
        }

        return MessageImageCard(
          imageUrl: imageUrl,
          allImageUrls: widget.message.imageUrls,
          imageIndex: index,
          fileName: fileName,
          fileSize: fileSize,
        );
      }).toList(),
    );
  }

  /// 渲染带块级数学公式的内容。
  /// 规则：使用正则表达式按 $$$$ 分割，公式部分使用 [Math.tex] 渲染，其他部分使用 MarkdownBody。
  Widget _buildContentWithMath({
    required BuildContext context,
    required String content,
    required MarkdownStyleSheet styleSheet,
    required CodeBlockSettings codeBlockSettings,
  }) {
    // 先将 \\[..\\] 格式的公式统一转换为 $$..$$，便于后续统一处理
    final normalizedContent = content.replaceAllMapped(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      (match) => '\$\$${match.group(1)}\$\$',
    );

    final mathRegex = RegExp(r'\$\$(.*?)\$\$', dotAll: true);
    final mermaidRegex = RegExp(r'```mermaid\s*\n(.*?)\n\s*```', dotAll: true);

    // Collect all matches
    final List<Match> allMatches = [];
    allMatches.addAll(mathRegex.allMatches(normalizedContent));

    // 添加 Mermaid 图表匹配
    final mermaidMatches = mermaidRegex.allMatches(normalizedContent);
    allMatches.addAll(mermaidMatches);

    // Sort by start index
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    int lastEnd = 0;
    final segments = <Widget>[];

    for (final match in allMatches) {
      if (match.start > lastEnd) {
        final text = normalizedContent.substring(lastEnd, match.start);
        if (text.trim().isNotEmpty) {
          segments.add(
            MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: styleSheet,
              inlineSyntaxes: [InlineLatexSyntax()],
              builders: {
                'code': CodeBlockBuilder(
                  codeBlockSettings: codeBlockSettings,
                  isFromUser: widget.message.isFromUser,
                ),
                'pre': CodeBlockBuilder(
                  codeBlockSettings: codeBlockSettings,
                  isFromUser: widget.message.isFromUser,
                ),
                'inline_math': InlineLatexBuilder(),
              },
              extensionSet: md.ExtensionSet.gitHubFlavored,
            ),
          );
        }
      }
      final content = match.group(1)!;
      if (match.pattern == mathRegex.pattern) {
        // Math
        segments.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Math.tex(
              content,
              mathStyle: MathStyle.display,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              onErrorFallback: (FlutterMathException e) {
                // 出现解析错误时，降级为普通文本显示
                // ignore: unnecessary_brace_in_string_interps
                return Text('\$\$${content}\$\$');
              },
            ),
          ),
        );
      } else {
        // Mermaid
        segments.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: codeBlockSettings.enableMermaidDiagrams
                ? EnhancedMermaidRenderer(mermaidCode: content)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mermaid图表 (已禁用)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }
      lastEnd = match.end;
    }

    // Last segment
    if (lastEnd < normalizedContent.length) {
      final text = normalizedContent.substring(lastEnd);
      if (text.trim().isNotEmpty) {
        segments.add(
          MarkdownBody(
            data: text,
            selectable: true,
            styleSheet: styleSheet,
            inlineSyntaxes: [InlineLatexSyntax()],
            builders: {
              'code': CodeBlockBuilder(
                codeBlockSettings: codeBlockSettings,
                isFromUser: widget.message.isFromUser,
              ),
              'pre': CodeBlockBuilder(
                codeBlockSettings: codeBlockSettings,
                isFromUser: widget.message.isFromUser,
              ),
              'inline_math': InlineLatexBuilder(),
            },
            extensionSet: md.ExtensionSet.gitHubFlavored,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments,
    );
  }
}

/// 代码块构建器
class CodeBlockBuilder extends MarkdownElementBuilder {
  final CodeBlockSettings codeBlockSettings;
  final bool isFromUser;

  CodeBlockBuilder({required this.codeBlockSettings, required this.isFromUser});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    var language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';

    // 如果没有指定语言，尝试自动检测
    if (language.isEmpty) {
      language = _detectLanguage(code);
    }

    return CodeBlockWidget(
      code: code,
      language: language,
      settings: codeBlockSettings,
      isFromUser: isFromUser,
    );
  }

  /// 混合语言检测：关键词优先 + 第三方包后备
  String _detectLanguage(String code) {
    final lowerCode = code.toLowerCase();

    // 优先使用关键词检测，避免误判
    if (lowerCode.contains('import pygame') ||
        lowerCode.contains('import random') ||
        lowerCode.contains('pygame.') ||
        lowerCode.contains('def ') ||
        lowerCode.contains('print(') ||
        (lowerCode.contains('import ') && lowerCode.contains('pygame'))) {
      return 'python';
    }

    if (lowerCode.contains('function') ||
        lowerCode.contains('const ') ||
        lowerCode.contains('let ') ||
        lowerCode.contains('console.log') ||
        lowerCode.contains('document.')) {
      return 'javascript';
    }

    if (lowerCode.contains('widget') ||
        lowerCode.contains('stateless') ||
        lowerCode.contains('stateful') ||
        lowerCode.contains('void main()') ||
        lowerCode.contains('flutter')) {
      return 'dart';
    }

    if (lowerCode.contains('public class') ||
        lowerCode.contains('public static void main') ||
        lowerCode.contains('system.out.')) {
      return 'java';
    }

    if (lowerCode.contains('<html') ||
        lowerCode.contains('<!doctype') ||
        lowerCode.contains('<div') ||
        lowerCode.contains('<body')) {
      return 'html';
    }

    if (lowerCode.trim().startsWith('{') &&
        lowerCode.trim().endsWith('}') &&
        lowerCode.contains('"') &&
        lowerCode.contains(':')) {
      return 'json';
    }

    // 优化的第三方包后备方案，减少重复计算
    try {
      const languages = [
        'python',
        'javascript',
        'dart',
        'java',
        'html',
        'css',
        'json',
        'bash',
        'sql',
        'xml',
        'cpp',
        'c',
      ];
      String bestLanguage = 'text';
      int bestRelevance = 0;

      for (final lang in languages) {
        try {
          final result = highlight.highlight.parse(code, language: lang);
          final relevance = result.relevance ?? 0;
          if (relevance > bestRelevance) {
            bestRelevance = relevance;
            bestLanguage = lang;
          }
        } catch (e) {
          continue;
        }
      }

      return bestRelevance > 8 ? bestLanguage : 'text';
    } catch (e) {
      return 'text';
    }
  }
}

/// 代码块组件
class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String language;
  final CodeBlockSettings settings;
  final bool isFromUser;

  const CodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
    required this.settings,
    required this.isFromUser,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

/// 语言信息类
class LanguageInfo {
  final IconData icon;
  final String displayName;

  const LanguageInfo({required this.icon, required this.displayName});
}

/// 语言信息映射表
const Map<String, LanguageInfo> _languageInfoMap = {
  'dart': LanguageInfo(icon: Icons.flutter_dash, displayName: 'Dart'),
  'python': LanguageInfo(icon: Icons.smart_toy, displayName: 'Python'),
  'javascript': LanguageInfo(icon: Icons.javascript, displayName: 'JavaScript'),
  'typescript': LanguageInfo(icon: Icons.javascript, displayName: 'TypeScript'),
  'java': LanguageInfo(icon: Icons.coffee, displayName: 'Java'),
  'html': LanguageInfo(icon: Icons.web, displayName: 'HTML'),
  'css': LanguageInfo(icon: Icons.style, displayName: 'CSS'),
  'json': LanguageInfo(icon: Icons.data_object, displayName: 'JSON'),
  'yaml': LanguageInfo(icon: Icons.settings, displayName: 'YAML'),
  'bash': LanguageInfo(icon: Icons.terminal, displayName: 'Shell'),
  'sql': LanguageInfo(icon: Icons.storage, displayName: 'SQL'),
  'text': LanguageInfo(icon: Icons.code, displayName: 'Plain Text'),
};

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _isExpanded = true;
  bool _showLineNumbers = true;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.settings.defaultCollapseCodeBlocks;
    _showLineNumbers = widget.settings.enableLineNumbers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 代码块头部
          _buildHeader(context),
          // 代码内容
          if (_isExpanded) _buildCodeContent(context),
        ],
      ),
    );
  }

  /// 构建代码块头部
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(
            _getLanguageIcon(widget.language),
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _getLanguageDisplayName(widget.language),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // 行号切换按钮
          if (widget.settings.enableLineNumbers)
            IconButton(
              icon: Icon(
                _showLineNumbers
                    ? Icons.format_list_numbered
                    : Icons.format_align_left,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _showLineNumbers = !_showLineNumbers;
                });
              },
              tooltip: _showLineNumbers ? '隐藏行号' : '显示行号',
            ),
          // 折叠/展开按钮
          if (widget.settings.enableCodeFolding)
            IconButton(
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              tooltip: _isExpanded ? '折叠代码' : '展开代码',
            ),
          // 复制按钮
          IconButton(
            icon: Icon(
              _isCopied ? Icons.check : Icons.copy,
              size: 16,
              color: _isCopied ? Colors.green : null,
            ),
            onPressed: () => _copyCode(context),
            tooltip: _isCopied ? '已复制' : '复制代码',
          ),
        ],
      ),
    );
  }

  /// 构建代码内容
  Widget _buildCodeContent(BuildContext context) {
    final lines = widget.code.split('\n');
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行号
          if (_showLineNumbers) _buildLineNumbers(lines, theme),
          // 代码内容
          Expanded(
            child: widget.settings.enableCodeWrapping
                ? _buildWrappableCode(theme)
                : _buildScrollableCode(theme),
          ),
        ],
      ),
    );
  }

  /// 构建行号
  Widget _buildLineNumbers(List<String> lines, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: lines.asMap().entries.map((entry) {
          return SizedBox(
            height: 20,
            child: Text(
              '${entry.key + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.end,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建可换行的代码
  Widget _buildWrappableCode(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final codeTheme = _getCodeTheme(isDark);

    return HighlightView(
      widget.code,
      language: widget.language,
      theme: codeTheme,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: const TextStyle(
        fontFamily: 'Source Code Pro, monospace',
        fontSize: 14,
      ),
    );
  }

  /// 构建可滚动的代码
  Widget _buildScrollableCode(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final codeTheme = _getCodeTheme(isDark);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          widget.code,
          language: widget.language,
          theme: codeTheme,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontFamily: 'Source Code Pro, monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 获取代码高亮主题
  Map<String, TextStyle> _getCodeTheme(bool isDark) {
    // 使用原来的 Atom One 主题
    final base = isDark ? atomOneDarkTheme : atomOneLightTheme;

    // 取消注释、文档标签、引用的斜体样式
    final fixed = Map<String, TextStyle>.from(base);
    const keys = ['comment', 'doctag', 'quote'];
    for (var k in keys) {
      if (fixed.containsKey(k)) {
        fixed[k] = fixed[k]!.copyWith(fontStyle: FontStyle.normal);
      }
    }
    return fixed;
  }

  /// 复制代码到剪贴板
  void _copyCode(BuildContext context) {
    if (_isCopied) return; // 防止重复点击

    Clipboard.setData(ClipboardData(text: widget.code));

    setState(() {
      _isCopied = true;
    });

    // 显示SnackBar反馈
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('代码已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );

    // 2秒后恢复按钮状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  /// 获取语言对应的图标
  IconData _getLanguageIcon(String language) {
    return _languageInfoMap[language.toLowerCase()]?.icon ?? Icons.code;
  }

  /// 获取语言的显示名称
  String _getLanguageDisplayName(String language) {
    return _languageInfoMap[language.toLowerCase()]?.displayName ??
        language.toUpperCase();
  }
}

/// 行内数学公式语法，例如 $a^2 + b^2=c^2$
class InlineLatexSyntax extends InlineSyntax {
  InlineLatexSyntax() : super(r'\$(?!\$)(.+?)(?<!\$)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final mathContent = match.group(1)!;
    parser.addNode(md.Element.text('inline_math', mathContent));
    return true;
  }
}

/// 行内数学公式Builder，将 Element 渲染为 Math.tex
class InlineLatexBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Math.tex(
      element.textContent,
      mathStyle: MathStyle.text,
      textStyle: preferredStyle,
      onErrorFallback: (e) => Text(element.textContent),
    );
  }
}
