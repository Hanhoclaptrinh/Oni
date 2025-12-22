class ReplyTo {
  final String messageId;
  final String senderId;
  final String type;
  final String? content;
  final String? fileUrl;

  ReplyTo({
    required this.messageId,
    required this.senderId,
    required this.type,
    this.content,
    this.fileUrl,
  });

  factory ReplyTo.fromJson(Map<String, dynamic> json) {
    return ReplyTo(
      messageId: json["messageId"],
      senderId: json["senderId"],
      type: json["type"] ?? "text",
      content: json["content"],
      fileUrl: json["fileUrl"],
    );
  }
}
