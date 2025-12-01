import 'package:flutter/material.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';
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
    // đọc RT từ FSS
    final localStorageService = LocalStorageService();
    String? refreshToken = await localStorageService.getToken();

    // không có refresh token
    if (refreshToken == null) {
      _navigateTo(AuthScreen());
      return;
    }

    // gửi yêu cầu cấp token mới
    try {
      final authService = AuthService();
      final authResult = await authService.refreshToken(refreshToken);

      // lưu RT mới vào FSS
      await localStorageService.saveToken(authResult.refreshToken);

      _navigateTo(MainScreen());
    } catch (e) {
      await localStorageService.clearToken();

      _navigateTo(AuthScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Future.delayed(Duration(microseconds: 1000), () {
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
