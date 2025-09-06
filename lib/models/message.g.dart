// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  content: json['content'] as String,
  sender: json['sender'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  appName: json['appName'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'sender': instance.sender,
  'timestamp': instance.timestamp.toIso8601String(),
  'type': _$MessageTypeEnumMap[instance.type]!,
  'appName': instance.appName,
};

const _$MessageTypeEnumMap = {
  MessageType.sms: 'sms',
  MessageType.notification: 'notification',
};
