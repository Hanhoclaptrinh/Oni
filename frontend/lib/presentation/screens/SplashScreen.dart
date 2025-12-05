import 'package:flutter/material.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/screens/AuthScreen.dart';
import 'package:frontend/presentation/screens/MainScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final local = LocalStorageService();
    final refreshToken = await local.getRefreshToken();

    if (refreshToken == null) {
      _navigateTo(const AuthScreen());
      return;
    }

    try {
      final authService = AuthService();
      final authResult = await authService.refreshToken(refreshToken);

      // lưu cả access + refresh
      await local.saveTokens(authResult.accessToken, authResult.refreshToken);

      final socketService = SocketService();
      socketService.connect(authResult.accessToken, authResult.user!.id);

      _navigateTo(const MainScreen());
    } catch (e) {
      await local.clear();
      _navigateTo(const AuthScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "oni.",
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
