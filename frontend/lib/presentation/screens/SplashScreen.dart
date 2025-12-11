import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/presentation/controllers/AuthProvider.dart';
import 'package:frontend/presentation/screens/AuthScreen.dart';
import 'package:frontend/presentation/screens/MainScreen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1500)),
      _processLogic(),
    ]);
  }

  Future<void> _processLogic() async {
    final local = LocalStorageService();
    final refreshToken = await local.getRefreshToken();

    if (refreshToken == null) {
      _goTo(const AuthScreen());
      return;
    }

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.refreshToken(refreshToken);

      await local.saveTokens(result.accessToken, result.refreshToken);

      _goTo(const MainScreen());
    } catch (e) {
      await local.clear();
      _goTo(const AuthScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
