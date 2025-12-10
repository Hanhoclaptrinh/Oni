import 'package:flutter/material.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
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
    _handleStartUp();
  }

  Future<void> _handleStartUp() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));

    final process = _processAuthLogic();

    await Future.wait([minDelay, process]);
  }

  Future<void> _processAuthLogic() async {
    final local = LocalStorageService();
    final refrshTkn = await local.getRefreshToken();

    if (refrshTkn == null) {
      _navigateTo(const AuthScreen());
      return;
    }

    try {
      final authService = AuthService();
      final authResult = await authService.refreshToken(refrshTkn);

      // lưu cả access + refresh
      await local.saveTokens(authResult.accessToken, authResult.refreshToken);

      SocketService().connect(authResult.accessToken);

      if (mounted) {
        _navigateTo(const MainScreen());
      }
    } catch (e) {
      await local.clear();
      SocketService().disconnect();
      if (mounted) {
        _navigateTo(const AuthScreen());
      }
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "oni.",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
