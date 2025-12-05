class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String? content;
  final String? fileUrl;
  final List<String> seenBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    this.fileUrl,
    required this.seenBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["_id"],
      conversationId: json["conversationId"]?.toString() ?? "",
      senderId: json["senderId"]?.toString() ?? "",
      type: json["type"] ?? "text",
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
    );
  }
}
