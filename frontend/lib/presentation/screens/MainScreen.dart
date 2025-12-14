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
import 'package:frontend/presentation/screens/HomeScreen.dart';
import 'package:frontend/presentation/screens/ProfileScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _pageIndex = 0;
  bool _socketInit = false;
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider);
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
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
                ref.read(cvsProvider.notifier).onNewGlobalMessage(msg, me.id);
              });
            }
          });
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _pageIndex,
          children: const [
            HomeScreen(),
            FriendScreen(),
            ConversationScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/home.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/home.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/friend.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/friend.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: 'Friend',
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/conversation.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/conversation.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: 'Chat',
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/profile.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/images/profile.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
