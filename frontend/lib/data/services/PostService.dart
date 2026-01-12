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

  Future<List<Post>> getPosts({int page = 1, int limit = 10}) async {
    final res = await dio.get(
      _postUrl,
      queryParameters: {'page': page, 'limit': limit},
    );
    final List data = res.data["data"];
    return data.map((json) => Post.fromJson(json)).toList();
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final res = await dio.get("$_postUrl/user/$userId");
    final List data = res.data["data"];
    return data.map((json) => Post.fromJson(json)).toList();
  }
}
