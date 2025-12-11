import 'package:dio/dio.dart';
import 'package:frontend/data/models/Message.dart';

class MessageService {
  final Dio dio;
  MessageService(this.dio);

  Future<List<Message>> getMessages(
    String conversationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    final res = await dio.get(
      "/messages/$conversationId",
      queryParameters: {"skip": skip, "limit": limit},
    );

    return (res.data["data"] as List).map((e) => Message.fromJson(e)).toList();
  }
}
