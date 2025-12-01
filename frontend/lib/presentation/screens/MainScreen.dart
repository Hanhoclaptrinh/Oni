import 'package:flutter/material.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/presentation/screens/ConversationScreen.dart';
import 'package:frontend/presentation/screens/FriendScreen.dart';
import 'package:frontend/presentation/screens/ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _pageIndex = 0;

  // xử lý chọn bottom item
  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // xử lý vuốt màn hình
  void _onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- TẠO DỮ LIỆU GIẢ Ở ĐÂY ---
    final UserProfile mockUser = UserProfile(
      username: "chaoem",
      email: "hanprovip@gmail.com",
      displayName: "Han Cuto",
      role: "user",
      avatarUrl: null,
      bio: "Mobile Developer | Flutter Enthusiast",
      emailVerified: false,
      createdAt: DateTime.now(),
    );

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            Center(child: Text("Home Screen")),
            FriendScreen(),
            Center(child: Text("Post Screen")),
            ConversationScreen(),
            ProfileScreen(user: mockUser),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Friend',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
