class LatestMessage {
  final String id;
  final String? content;
  final DateTime createdAt;

  LatestMessage({
    required this.id,
    this.content,
    required this.createdAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json["_id"],
      content: json["content"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
