class Post {
  final String? id;
  final String? authorId;
  final String content;
  final List<String> images;
  final String? video;
  final String visibility;
  final DateTime? createdAt;
  final int? likeCount;
  final int? commentCount;
  final int? shareCount;

  Post({
    this.id,
    this.authorId,
    required this.content,
    required this.images,
    this.video,
    required this.visibility,
    this.createdAt,
    this.likeCount,
    this.commentCount,
    this.shareCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      authorId: json['authorId'],
      content: json['content'] ?? "",
      images: List<String>.from(json['images'] ?? []),
      video: json['video'],
      visibility: json['visibility'] ?? "public",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'images': images,
      if (video != null) 'video': video,
      'visibility': visibility,
    };
  }
}
