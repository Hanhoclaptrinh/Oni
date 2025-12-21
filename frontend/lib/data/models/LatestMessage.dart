import 'package:frontend/data/models/Message.dart';

class LatestMessage {
  final String id;
  final String? content;
  final String type;
  final DateTime createdAt;
  DateTime? editedAt;
  final bool isMine;

  LatestMessage({
    required this.id,
    this.content,
    required this.type,
    required this.createdAt,
    this.editedAt,
    required this.isMine,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json["_id"],
      content: json["content"],
      type: json["status"] ?? json["type"] ?? "text",
      createdAt: DateTime.parse(json["createdAt"]),
      editedAt: json["editedAt"] != null
          ? DateTime.parse(json["editedAt"])
          : null,
      isMine: json["isMine"] ?? false,
    );
  }

  factory LatestMessage.fromMessage(Message msg, bool isMine) {
    return LatestMessage(
      id: msg.id,
      content: msg.content,
      type: msg.status,
      createdAt: msg.createdAt,
      editedAt: msg.editedAt,
      isMine: isMine,
    );
  }

  LatestMessage copyWith({String? content, String? type, DateTime? editedAt}) {
    return LatestMessage(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt,
      editedAt: editedAt,
      isMine: isMine,
    );
  }
}
