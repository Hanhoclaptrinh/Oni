import 'package:dio/dio.dart';
import 'package:frontend/data/models/Conversation.dart';

class ConversationService {
  final Dio dio;

  ConversationService(this.dio);

  Future<List<Conversation>> getMyConversations() async {
    final res = await dio.get("/conversations/me");
    final list = res.data["data"] as List;
    return list.map((e) => Conversation.fromJson(e)).toList();
  }
}
