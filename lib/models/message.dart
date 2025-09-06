import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String content;
  final String sender;
  final DateTime timestamp;
  final MessageType type;
  final String? appName;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.type,
    this.appName,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? content,
    String? sender,
    DateTime? timestamp,
    MessageType? type,
    String? appName,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      appName: appName ?? this.appName,
    );
  }
}

enum MessageType {
  sms,
  notification,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.sms:
        return 'SMS';
      case MessageType.notification:
        return 'Notification';
    }
  }
}

