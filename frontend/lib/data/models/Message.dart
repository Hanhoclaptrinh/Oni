import 'package:frontend/core/utils/MessageStatus.dart';
import 'package:frontend/data/models/Media.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String status; // trang thai tin nhan revoked / normal
  final MessageStatus? msgStatusSending; // trang thai gui cua tin nhan
  final String? content;
  final Media? media;
  final List<String> seenBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  DateTime? editedAt;
  final String? replyTo;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.status,
    required this.msgStatusSending,
    this.content,
    this.media,
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
      msgStatusSending: MessageStatus.sent,
      content: json["content"],
      media: json["media"] != null ? Media.fromJson(json["media"]) : null,
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
      replyTo: json["replyTo"]?.toString(),
    );
  }

  // copy with
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? type,
    String? status,
    MessageStatus? msgStatusSending,
    String? content,
    Media? media,
    List<String>? seenBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    String? replyTo,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    type: type ?? this.type,
    status: status ?? this.status,
    msgStatusSending: msgStatusSending,
    content: content ?? this.content,
    media: media ?? this.media,
    seenBy: seenBy ?? this.seenBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    editedAt: editedAt ?? this.editedAt,
    replyTo: replyTo ?? this.replyTo,
  );
}
