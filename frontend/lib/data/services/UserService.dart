import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/models/User.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';

class UserService {
  late Dio _dio;
  final LocalStorageService _local = LocalStorageService();

  UserService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _local.getAccessToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          // nếu bị 401 thì thử refresh token
          if (e.response?.statusCode == 401) {
            final refreshToken = await _local.getRefreshToken();

            if (refreshToken != null) {
              try {
                final authResult = await AuthService().refreshToken(
                  refreshToken,
                );

                // lưu token mới
                await _local.saveTokens(
                  authResult.accessToken,
                  authResult.refreshToken,
                );

                // retry request cũ
                final newRequest = await _retry(e.requestOptions);
                return handler.resolve(newRequest);
              } catch (_) {
                // refresh fail → logout
                await _local.clear();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // retry logic
  Future<Response<dynamic>> _retry(RequestOptions request) async {
    final newToken = await _local.getAccessToken();

    final opts = Options(
      method: request.method,
      headers: {...request.headers, "Authorization": "Bearer $newToken"},
    );

    return _dio.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: opts,
    );
  }

  static const _profileUrl = "/users/me";

  Future<User> getProfile() async {
    final res = await _dio.get(_profileUrl);

    final data = res.data["data"];

    return User.fromJson(data);
  }
}
