import 'package:dio/dio.dart';
import 'package:frontend/data/models/Post.dart';

class PostService {
  final Dio dio;

  PostService(this.dio);

  static const _postUrl = "/posts";

  Future<Post> createPost(Post post) async {
    final res = await dio.post(_postUrl, data: post.toJson());
    return Post.fromJson(res.data["data"]);
  }
}
