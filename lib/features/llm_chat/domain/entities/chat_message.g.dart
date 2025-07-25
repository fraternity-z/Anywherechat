// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FileAttachmentImpl _$$FileAttachmentImplFromJson(Map<String, dynamic> json) =>
    _$FileAttachmentImpl(
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      fileType: json['fileType'] as String,
      filePath: json['filePath'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$$FileAttachmentImplToJson(
        _$FileAttachmentImpl instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'fileType': instance.fileType,
      'filePath': instance.filePath,
      'content': instance.content,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      isFromUser: json['isFromUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      chatSessionId: json['chatSessionId'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sent,
      metadata: json['metadata'] as Map<String, dynamic>?,
      parentMessageId: json['parentMessageId'] as String?,
      tokenCount: (json['tokenCount'] as num?)?.toInt(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => FileAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      thinkingContent: json['thinkingContent'] as String?,
      thinkingComplete: json['thinkingComplete'] as bool? ?? false,
      modelName: json['modelName'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isFromUser': instance.isFromUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'chatSessionId': instance.chatSessionId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'parentMessageId': instance.parentMessageId,
      'tokenCount': instance.tokenCount,
      'imageUrls': instance.imageUrls,
      'attachments': instance.attachments,
      'thinkingContent': instance.thinkingContent,
      'thinkingComplete': instance.thinkingComplete,
      'modelName': instance.modelName,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.system: 'system',
  MessageType.error: 'error',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.failed: 'failed',
  MessageStatus.read: 'read',
};
