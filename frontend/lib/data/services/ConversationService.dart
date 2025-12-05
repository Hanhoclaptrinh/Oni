import 'package:dio/dio.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/services/LocalStorageService.dart';

class ConversationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  static const _myConversationUrl = "/conversations/me";

  Future<List<Conversation>> getMyConversations() async {
    try {
      final token = await LocalStorageService().getAccessToken();

      final res = await _dio.get(
        _myConversationUrl,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        })
      );

      final data = res.data["data"] as List;

      return data.map((cvs) => Conversation.fromJson(cvs)).toList();
    } catch (e) {
      rethrow;
    }
  }
}