import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/models/AuthResult.dart';
import 'package:frontend/data/models/SigninRequest.dart';
import 'package:frontend/data/models/SignupRequest.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl)); // api route

  static const _signUpUrl = "/auth/signup";
  static const _signInUrl = "/auth/signin";
  static const _signOutUrl = "/auth/signout";
  static const _refreshTokenUrl = "/auth/refresh";

  Future<AuthResult> signup(SignupRequest req) async {
    try {
      final res = await _dio.post(_signUpUrl, data: req.toJson());
      return AuthResult.fromJson(res.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResult> signin(SigninRequest req) async {
    try {
      final res = await _dio.post(_signInUrl, data: req.toJson());
      return AuthResult.fromJson(res.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signout(String refreshToken) async {
    try {
      await _dio.post(_signOutUrl, data: {"refreshToken": refreshToken});
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResult> refreshToken(String? refreshToken) async {
    try {
      final res = await _dio.post(
        _refreshTokenUrl,
        data: {"refreshToken": refreshToken},
      );

      return AuthResult.fromJson(res.data["data"]);
    } catch (e) {
      rethrow;
    }
  }
}
