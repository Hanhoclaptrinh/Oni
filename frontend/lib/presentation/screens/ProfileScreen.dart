import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/User.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:frontend/presentation/screens/EditProfileScreen.dart';
import 'package:frontend/data/models/Post.dart';
import 'package:frontend/providers/PostProvider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: me.when(
          data: (user) => Row(
            children: [
              const Icon(Icons.lock_outline, size: 18, color: Colors.black),
              const SizedBox(width: 5),
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: me.when(
        data: (user) {
          return FutureBuilder<List<Post>>(
            future: ref.read(postServiceProvider).getUserPosts(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}"));
              }

              final posts = snapshot.data ?? [];
              final photoPosts = posts
                  .where((p) => p.images.isNotEmpty == true)
                  .toList();
              final videoPosts = posts.where((p) => p.video != null).toList();

              return DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          _buildProfileHeader(context, user),
                        ]),
                      ),
                    ];
                  },
                  body: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.black,
                        indicatorWeight: 1,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(icon: Icon(Icons.grid_on_sharp)),
                          Tab(icon: Icon(Icons.video_call)),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildPhotoGrid(photoPosts),
                            _buildVideoGrid(videoPosts),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar + stats
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    user.avatarUrl ?? "https://i.pravatar.cc/300?img=12",
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(user.postCount.toString(), "Bài viết"),
                    _buildStatColumn(
                      user.followersCount.toString(),
                      "Người theo dõi",
                    ),
                    _buildStatColumn(
                      user.followingCount.toString(),
                      "Đang theo dõi",
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.bio!,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],

          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              color: Color(0xFF00376B),
              fontWeight: FontWeight.w500,
            ),
          ),

          // action buttons
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  label: "Chỉnh sửa trang cá nhân",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: "Chia sẻ trang cá nhân",
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text("Chưa có ảnh nào", style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final imageUrl = post.images.first;
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text("Chưa có video nào", style: TextStyle(color: Colors.grey)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        // hien thi thumbnail video
        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}
