import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/keyboard_dismissible_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'constants/ui_constants.dart';
import 'navigation/sidebar_container.dart';
import 'navigation/assistants_tab.dart';
import 'navigation/topics_tab.dart';
import 'navigation/settings_tab.dart';

import '../features/llm_chat/presentation/views/chat_screen.dart';
import '../features/settings/presentation/views/settings_screen.dart';
import '../features/settings/presentation/views/general_settings_screen.dart';
import '../features/settings/presentation/views/appearance_settings_screen.dart';
import '../features/settings/presentation/views/data_management_screen.dart';
import '../features/settings/presentation/views/about_screen.dart';
import '../features/settings/presentation/views/model_management_screen.dart';
import '../features/settings/presentation/views/provider_config_screen.dart';
import '../features/settings/presentation/providers/ui_settings_provider.dart';
import '../features/knowledge_base/presentation/views/knowledge_base_screen.dart';

/// 侧边栏标签页状态管理
final sidebarTabProvider = StateProvider<SidebarTab>(
  (ref) => SidebarTab.assistants,
);

/// 模型参数设置状态管理
class ModelParameters {
  final double temperature;
  final double maxTokens;
  final double topP;
  final double contextLength;
  final bool enableMaxTokens;

  const ModelParameters({
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.topP = 0.9,
    this.contextLength = 10,
    this.enableMaxTokens = true,
  });

  ModelParameters copyWith({
    double? temperature,
    double? maxTokens,
    double? topP,
    double? contextLength,
    bool? enableMaxTokens,
  }) {
    return ModelParameters(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      contextLength: contextLength ?? this.contextLength,
      enableMaxTokens: enableMaxTokens ?? this.enableMaxTokens,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'contextLength': contextLength,
      'enableMaxTokens': enableMaxTokens,
    };
  }

  /// 从JSON创建实例
  factory ModelParameters.fromJson(Map<String, dynamic> json) {
    return ModelParameters(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toDouble() ?? 2048,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      contextLength: (json['contextLength'] as num?)?.toDouble() ?? 10,
      enableMaxTokens: json['enableMaxTokens'] as bool? ?? true,
    );
  }
}

/// 模型参数状态管理器
class ModelParametersNotifier extends StateNotifier<ModelParameters> {
  ModelParametersNotifier() : super(const ModelParameters()) {
    _loadParameters();
  }

  /// 加载参数
  Future<void> _loadParameters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parametersJson = prefs.getString('model_parameters');

      if (parametersJson != null) {
        final parametersMap =
            json.decode(parametersJson) as Map<String, dynamic>;
        state = ModelParameters.fromJson(parametersMap);
        debugPrint('📊 模型参数已加载: ${state.toJson()}');
      }
    } catch (e) {
      debugPrint('❌ 加载模型参数失败: $e');
    }
  }

  /// 保存参数
  Future<void> _saveParameters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parametersJson = json.encode(state.toJson());
      await prefs.setString('model_parameters', parametersJson);
      debugPrint('💾 模型参数已保存: ${state.toJson()}');
    } catch (e) {
      debugPrint('❌ 保存模型参数失败: $e');
    }
  }

  /// 更新温度
  Future<void> updateTemperature(double temperature) async {
    state = state.copyWith(temperature: temperature);
    await _saveParameters();
  }

  /// 更新最大Token数
  Future<void> updateMaxTokens(double maxTokens) async {
    state = state.copyWith(maxTokens: maxTokens);
    await _saveParameters();
  }

  /// 更新Top-P
  Future<void> updateTopP(double topP) async {
    state = state.copyWith(topP: topP);
    await _saveParameters();
  }

  /// 更新上下文长度
  Future<void> updateContextLength(double contextLength) async {
    state = state.copyWith(contextLength: contextLength);
    await _saveParameters();
  }

  /// 更新是否启用最大Token限制
  Future<void> updateEnableMaxTokens(bool enableMaxTokens) async {
    state = state.copyWith(enableMaxTokens: enableMaxTokens);
    await _saveParameters();
  }

  /// 重置参数
  Future<void> resetParameters() async {
    state = const ModelParameters();
    await _saveParameters();
  }
}

final modelParametersProvider =
    StateNotifierProvider<ModelParametersNotifier, ModelParameters>((ref) {
      return ModelParametersNotifier();
    });

/// 代码块设置状态管理
class CodeBlockSettings {
  final bool enableCodeEditing;
  final bool enableLineNumbers;
  final bool enableCodeFolding;
  final bool enableCodeWrapping;
  final bool defaultCollapseCodeBlocks;
  final bool enableMermaidDiagrams;

  const CodeBlockSettings({
    this.enableCodeEditing = true,
    this.enableLineNumbers = true,
    this.enableCodeFolding = true,
    this.enableCodeWrapping = true,
    this.defaultCollapseCodeBlocks = false,
    this.enableMermaidDiagrams = true,
  });

  CodeBlockSettings copyWith({
    bool? enableCodeEditing,
    bool? enableLineNumbers,
    bool? enableCodeFolding,
    bool? enableCodeWrapping,
    bool? defaultCollapseCodeBlocks,
    bool? enableMermaidDiagrams,
  }) {
    return CodeBlockSettings(
      enableCodeEditing: enableCodeEditing ?? this.enableCodeEditing,
      enableLineNumbers: enableLineNumbers ?? this.enableLineNumbers,
      enableCodeFolding: enableCodeFolding ?? this.enableCodeFolding,
      enableCodeWrapping: enableCodeWrapping ?? this.enableCodeWrapping,
      defaultCollapseCodeBlocks:
          defaultCollapseCodeBlocks ?? this.defaultCollapseCodeBlocks,
      enableMermaidDiagrams:
          enableMermaidDiagrams ?? this.enableMermaidDiagrams,
    );
  }
}

final codeBlockSettingsProvider = StateProvider<CodeBlockSettings>((ref) {
  return const CodeBlockSettings();
});

/// 常规设置状态管理
class GeneralSettings {
  final bool enableMarkdownRendering;
  final bool enableAutoSave;
  final bool enableNotifications;
  final String language;
  final String mathEngine;

  const GeneralSettings({
    this.enableMarkdownRendering = true,
    this.enableAutoSave = true,
    this.enableNotifications = true,
    this.language = 'zh-CN',
    this.mathEngine = 'katex',
  });

  GeneralSettings copyWith({
    bool? enableMarkdownRendering,
    bool? enableAutoSave,
    bool? enableNotifications,
    String? language,
    String? mathEngine,
  }) {
    return GeneralSettings(
      enableMarkdownRendering:
          enableMarkdownRendering ?? this.enableMarkdownRendering,
      enableAutoSave: enableAutoSave ?? this.enableAutoSave,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      language: language ?? this.language,
      mathEngine: mathEngine ?? this.mathEngine,
    );
  }
}

final generalSettingsProvider = StateProvider<GeneralSettings>((ref) {
  return const GeneralSettings();
});

/// 侧边栏折叠状态管理
final sidebarModelParamsExpandedProvider = StateProvider<bool>((ref) => false);
final sidebarCodeBlockExpandedProvider = StateProvider<bool>((ref) => false);
final sidebarGeneralExpandedProvider = StateProvider<bool>((ref) => false);

/// 应用路由配置
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    debugLogDiagnostics: true,
    routes: [
      // Shell路由 - 提供统一的导航框架
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // LLM聊天功能
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),

          // 知识库
          GoRoute(
            path: '/knowledge',
            name: 'knowledge',
            builder: (context, state) => const KnowledgeBaseScreen(),
          ),

          // 设置
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              // 常规设置
              GoRoute(
                path: 'general',
                name: 'general-settings',
                builder: (context, state) => const GeneralSettingsScreen(),
              ),
              // 模型管理
              GoRoute(
                path: 'models',
                name: 'model-management',
                builder: (context, state) => const ModelManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'provider/:providerId',
                    name: 'provider-config',
                    builder: (context, state) {
                      final providerId = state.pathParameters['providerId']!;
                      return ProviderConfigScreen(providerId: providerId);
                    },
                  ),
                ],
              ),
              // 外观设置
              GoRoute(
                path: 'appearance',
                name: 'appearance-settings',
                builder: (context, state) => const AppearanceSettingsScreen(),
              ),
              // 数据管理
              GoRoute(
                path: 'data',
                name: 'data-management',
                builder: (context, state) => const DataManagementScreen(),
              ),
              // 关于
              GoRoute(
                path: 'about',
                name: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // 错误页面
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

/// 主要的Shell布局，包含侧边栏导航
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _hasModalRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateModalRouteState();
    });
  }

  void _updateModalRouteState() {
    final newState = Navigator.of(context).canPop();
    if (newState != _hasModalRoute) {
      setState(() {
        _hasModalRoute = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final currentRoute = GoRouterState.of(context).uri.path;
    final isChatPage = currentRoute.startsWith('/chat');

    return KeyboardSafeWrapper(
      child: Scaffold(
        floatingActionButton: (isCollapsed && isChatPage && !_hasModalRoute)
            ? const SidebarExpandButton()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: Stack(
          children: [
            widget.child,
            if (!isCollapsed) ...[
              const SidebarOverlay(),
              const NavigationSidebar(),
            ],
          ],
        ),
      ),
    );
  }
}

/// 侧边导航栏
class NavigationSidebar extends ConsumerWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(sidebarTabProvider);

    return SidebarContainer(
      child: Column(
        children: [
          const SidebarHeader(),
          SidebarTabBar(
            selectedTab: selectedTab,
            onTabSelected: (tab) {
              ref.read(sidebarTabProvider.notifier).state = tab;
            },
          ),
          Expanded(child: _buildTabContent(selectedTab)),
        ],
      ),
    );
  }

  /// 构建标签页内容
  Widget _buildTabContent(SidebarTab selectedTab) {
    return IndexedStack(
      index: selectedTab.index,
      children: const [AssistantsTab(), TopicsTab(), SettingsTab()],
    );
  }
}

/// 错误页面
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面加载失败', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '未知错误',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
