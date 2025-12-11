import 'package:dio/dio.dart';
import 'package:frontend/data/models/User.dart';

class UserService {
  final Dio dio;

  UserService(this.dio);

  static const _profileUrl = "/users/me";

  Future<User> getProfile() async {
    final res = await dio.get(_profileUrl);
    return User.fromJson(res.data["data"]);
  }
}
