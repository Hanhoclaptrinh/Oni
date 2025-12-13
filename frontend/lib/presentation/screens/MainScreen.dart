import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/providers/ConversationProvider.dart';
import 'package:frontend/presentation/providers/UserProvider.dart';
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

  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();

    // load user info
    Future.microtask(() {
      ref.read(userProvider);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _msgSub?.cancel();
    _pageController.dispose();
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

          LocalStorageService().getAccessToken().then((token) {
            if (token != null) {
              final socketService = SocketService();
              socketService.connect(token);

              _msgSub = socketService.messageStream.listen((data) {
                final msg = Message.fromJson(data);
                ref.read(cvsProvider.notifier).onNewGlobalMessage(msg);
              });
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
