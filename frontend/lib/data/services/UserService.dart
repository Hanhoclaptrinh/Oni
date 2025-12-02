import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/models/User.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  static const _profileUrl = "users/me";

  Future<User> getProfile() async {
    try {
      final res = await _dio.get(_profileUrl);
      return User.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }
}
