import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/controllers/UserProvider.dart';
import 'package:frontend/presentation/screens/ConversationScreen.dart';
import 'package:frontend/presentation/screens/FriendScreen.dart';
import 'package:frontend/presentation/screens/ProfileScreen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _pageIndex = 0;

  bool _socketInit = false;

  @override
  void initState() {
    super.initState();

    // load user info
    Future.microtask(() {
      ref.read(userProvider);
    });
  }

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
    final meAsync = ref.watch(userProvider);

    meAsync.whenOrNull(
      data: (me) {
        if (!_socketInit) {
          _socketInit = true;

          // lấy token để connect socket
          LocalStorageService().getAccessToken().then((token) {
            if (token != null) {
              SocketService().connect(token);
            }
          });
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            Center(child: Text("Home Screen")),
            FriendScreen(),
            ConversationScreen(),
            ProfileScreen(),
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
