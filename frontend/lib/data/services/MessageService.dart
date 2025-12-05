import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/LocalStorageService.dart';

class MessageService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<List<Message>> getMessages(
    String conversationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final token = await LocalStorageService().getAccessToken();

      final res = await _dio.get(
        "/messages/$conversationId",
        queryParameters: {"skip": skip, "limit": limit},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final list = (res.data["data"] as List)
          .map((json) => Message.fromJson(json))
          .toList();

      return list;
    } catch (e) {
      rethrow;
    }
  }
}
