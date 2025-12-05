// model User chỉ nhận dữ liệu trả về từ server
// không dùng để gửi dữ liệu lên server
class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? coverImgUrl;
  final String role;
  final bool emailVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.coverImgUrl,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
  });

  // lấy dữ liệu từ json và chuyển thành User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? "",
      username: json['username'] ?? "Unknown",
      email: json['email'] ?? "",
      displayName: json['displayName'] ?? "",
      bio: json['bio'] ?? "",
      avatarUrl: json['avatarUrl'] ?? "",
      coverImgUrl: json['coverImgUrl'],
      role: json['role'] ?? "user",
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }
}
