import 'package:dio/dio.dart';
import 'package:frontend/data/models/AuthResult.dart';
import 'package:frontend/data/models/SigninRequest.dart';
import 'package:frontend/data/models/SignupRequest.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  static const _signUpUrl = "/auth/signup";
  static const _signInUrl = "/auth/signin";
  static const _signOutUrl = "/auth/signout";
  static const _refreshTokenUrl = "/auth/refresh";

  Future<AuthResult> signup(SignupRequest req) async {
    final res = await dio.post(_signUpUrl, data: req.toJson());
    return AuthResult.fromJson(res.data["data"]);
  }

  Future<AuthResult> signin(SigninRequest req) async {
    final res = await dio.post(_signInUrl, data: req.toJson());
    return AuthResult.fromJson(res.data["data"]);
  }

  Future<void> signout(String refreshToken) async {
    await dio.post(_signOutUrl, data: {"refreshToken": refreshToken});
  }

  Future<AuthResult> refreshToken(String refreshToken) async {
    final res = await dio.post(
      _refreshTokenUrl,
      data: {"refreshToken": refreshToken},
    );
    return AuthResult.fromJson(res.data["data"]);
  }
}
