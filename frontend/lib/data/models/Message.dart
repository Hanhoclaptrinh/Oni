import 'package:frontend/data/models/ReplyTo.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String status;
  final String? content;
  final String? fileUrl;
  final List<String> seenBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  DateTime? editedAt;
  final ReplyTo? replyTo;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.status,
    this.content,
    this.fileUrl,
    required this.seenBy,
    required this.createdAt,
    required this.updatedAt,
    this.editedAt,
    this.replyTo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["_id"].toString(),
      conversationId: json["conversationId"].toString(),
      senderId: json["senderId"]?.toString() ?? "",
      type: json["type"] ?? "text",
      status: json["status"],
      content: json["content"],
      fileUrl: json["fileUrl"],
      seenBy: json["seenBy"] != null
          ? List<String>.from(json["seenBy"].map((id) => id.toString()))
          : [],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : DateTime.now(),
      editedAt: json["editedAt"] != null
          ? DateTime.parse(json["editedAt"])
          : null,
      replyTo: json["replyTo"] != null
          ? ReplyTo.fromJson(json["replyTo"])
          : null,
    );
  }

  // copy with
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? type,
    String? status,
    String? content,
    String? fileUrl,
    List<String>? seenBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    ReplyTo? replyTo,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    type: type ?? this.type,
    status: status ?? this.status,
    content: content ?? this.content,
    fileUrl: fileUrl ?? this.fileUrl,
    seenBy: seenBy ?? this.seenBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    editedAt: editedAt ?? this.editedAt,
    replyTo: replyTo ?? this.replyTo,
  );
}
