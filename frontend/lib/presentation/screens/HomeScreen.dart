import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/SocialPostCard.dart';
import 'package:frontend/presentation/screens/PostScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [_buildSliverAppBar(), _buildSearchBar(), _buildPostList()],
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
  Widget _buildPostList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return SocialPostCard(
            userName: "Nettie Fernandez",
            userAvatarUrl: "https://i.pravatar.cc/150?img=5",
            timeAgo: "Just now",
            textContent:
                "Thinking about overseas adventure travel? Have you put any thought into the best places",
            imageUrls: const ["https://picsum.photos/600/600"],
            likeCount: 439,
            commentCount: 34,
          );
        } else if (index == 1) {
          return SocialPostCard(
            userName: "Design World",
            userAvatarUrl: "https://i.pravatar.cc/150?img=12",
            timeAgo: "2 hours ago",
            textContent:
                "Minimalist UI design is trending right now. Check out this clean interface.",
            imageUrls: null,
            likeCount: 120,
            commentCount: 15,
          );
        } else {
          return SocialPostCard(
            userName: "Photography Hub",
            userAvatarUrl: "https://i.pravatar.cc/150?img=3",
            timeAgo: "1 day ago",
            textContent: null,
            imageUrls: const [
              "https://picsum.photos/600/400",
              "https://picsum.photos/600/401",
            ],
            likeCount: 890,
            commentCount: 56,
          );
        }
      }, childCount: 10),
    );
  }
}
