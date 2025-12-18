import 'package:frontend/data/models/Message.dart';

class LatestMessage {
  final String id;
  final String? content;
  final String type;
  final DateTime createdAt;

  LatestMessage({
    required this.id,
    this.content,
    required this.type,
    required this.createdAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json["_id"],
      content: json["content"],
      type: json["status"] ?? json["type"] ?? "text",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  factory LatestMessage.fromMessage(Message msg) {
    return LatestMessage(
      id: msg.id,
      content: msg.content,
      type: msg.status,
      createdAt: msg.createdAt,
    );
  }

  LatestMessage copyWith({String? content, String? type}) {
    return LatestMessage(
      id: id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt,
    );
  }
}
