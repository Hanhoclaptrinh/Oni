import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/Post.dart';
import 'package:frontend/data/services/PostService.dart';
import 'package:frontend/providers/DioProvider.dart';

final postServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PostService(dio);
});

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  () => PostsNotifier(),
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    return await ref.read(postServiceProvider).getPosts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(postServiceProvider).getPosts(),
    );
  }

  void addPost(Post post) {
    if (state.hasValue) {
      state = AsyncValue.data([post, ...state.value!]);
    }
  }
}
