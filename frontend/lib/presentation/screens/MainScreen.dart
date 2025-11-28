import 'package:flutter/material.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';
import 'package:frontend/presentation/screens/AuthScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _handleSignOut() async {
    final localStorageService = LocalStorageService();
    String? refreshToken = await localStorageService.getToken();

    if (refreshToken == null) {
      _removeTokenAndRedirect();
    }

    try {
      final authService = AuthService();
      await authService.signout(refreshToken!);

      _removeTokenAndRedirect();
    } catch (e) {
      throw e;
    }
  }

  void _removeTokenAndRedirect() async {
    final localStorageService = LocalStorageService();
    await localStorageService.clearToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Main content here"),
            SizedBox(height: 50),
            TextButton.icon(
              onPressed: _handleSignOut,
              label: Text("Đăng xuất"),
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
