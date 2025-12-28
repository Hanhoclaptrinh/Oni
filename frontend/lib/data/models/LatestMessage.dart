import 'package:frontend/core/utils/Enums.dart';
import 'package:frontend/data/models/Message.dart';

class LatestMessage {
  final String id;
  final String? content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String senderId;

  LatestMessage({
    required this.id,
    this.content,
    required this.type,
    required this.createdAt,
    this.editedAt,
    required this.senderId,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json["_id"],
      content: json["content"],
      type: MessageType.values.firstWhere((e) => e.name == json["type"]),
      createdAt: DateTime.parse(json["createdAt"]),
      editedAt: json["editedAt"] != null
          ? DateTime.parse(json["editedAt"])
          : null,
      senderId: json["senderId"] ?? "",
    );
  }

  factory LatestMessage.fromMessage(Message msg, bool isMine) {
    return LatestMessage(
      id: msg.id,
      content: msg.content,
      type: msg.type,
      createdAt: msg.createdAt,
      editedAt: msg.editedAt,
      senderId: msg.senderId,
    );
  }

  LatestMessage copyWith({
    String? content,
    MessageType? type,
    DateTime? editedAt,
  }) {
    return LatestMessage(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt,
      editedAt: editedAt,
      senderId: senderId,
    );
  }

  String get previewText {
    switch (type) {
      case MessageType.text:
        return content ?? "";
      case MessageType.media:
        return "📎 Đã gửi file";
    }
  }
}
