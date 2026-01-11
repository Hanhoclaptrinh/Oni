class Post {
  final String? id;
  final String? authorId;
  final PostAuthor? author;
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
    this.author,
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
    String? authorId;
    PostAuthor? author;

    if (json['authorId'] is Map) {
      author = PostAuthor.fromJson(json['authorId']);
      authorId = author.id;
    } else {
      authorId = json['authorId'];
    }

    return Post(
      id: json['_id'],
      authorId: authorId,
      author: author,
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

class PostAuthor {
  final String id;
  final String displayName;
  final String? avatarUrl;

  PostAuthor({required this.id, required this.displayName, this.avatarUrl});

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['_id'],
      displayName: json['displayName'] ?? "Người dùng",
      avatarUrl: json['avatarUrl'],
    );
  }
}
