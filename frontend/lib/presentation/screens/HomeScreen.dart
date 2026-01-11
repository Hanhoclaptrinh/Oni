import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/Post.dart';
import 'package:frontend/providers/PostProvider.dart';
import 'package:frontend/presentation/widgets/SocialPostCard.dart';
import 'package:frontend/presentation/screens/PostScreen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => ref.read(postsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            _buildSearchBar(),
            postsAsync.when(
              data: (posts) => _buildPostList(posts),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text("Lỗi tải bài viết: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // sliver app bar
  Widget _buildSliverAppBar() {
    const Color appTextDark = Colors.black;

    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 80,

      // add  post button
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_rounded, color: appTextDark),
              iconSize: 24,
              // navigate to post screen
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostScreen()),
                );
              },
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
        title: const Text(
          "Oni",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: appTextDark,
          ),
        ),
      ),
    );
  }

  // search bar
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const TextField(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search_rounded, color: Colors.black),
              hintText: "Search",
              hintStyle: TextStyle(
                color: Color(0xFFC0C0C0),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // post list
  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("Chưa có bài viết nào.")),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = posts[index];
        return SocialPostCard(
          userName: post.author?.displayName ?? "Người dùng",
          userAvatarUrl:
              post.author?.avatarUrl ??
              "https://ui-avatars.com/api/?name=${post.author?.displayName ?? 'User'}",
          timeAgo: post.createdAt != null
              ? _formatTimeAgo(post.createdAt!)
              : "Vừa xong",
          textContent: post.content,
          imageUrls: post.images,
          videoUrl: post.video,
          likeCount: post.likeCount ?? 0,
          commentCount: post.commentCount ?? 0,
        );
      }, childCount: posts.length),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inDays > 0) return DateFormat('dd/MM/yyyy').format(date);
    if (duration.inHours > 0) return '${duration.inHours} giờ trước';
    if (duration.inMinutes > 0) return '${duration.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
