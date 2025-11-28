import 'package:frontend/data/models/User.dart';

// kết quả trả về từ server sau khi đăng ký hoặc đăng nhập
class AuthResult {
  User? user;
  final String accessToken;
  final String refreshToken;

  AuthResult({
    this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userData = json["user"];
    return AuthResult(
      user: userData != null ? User.fromJson(json['user']) : null,
      accessToken: json['accessToken'] ?? json['newAccessToken'],
      refreshToken: json['refreshToken'] ?? json['newRefreshToken'],
    );
  }
}
