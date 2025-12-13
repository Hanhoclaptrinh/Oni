import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/providers/AuthProvider.dart';
import 'package:frontend/presentation/screens/AuthScreen.dart';
import 'package:frontend/presentation/screens/MainScreen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  static const double progressBarWidth = 280.0;
  static const double progressBarHeight = 12.0;
  static const double borderRadius = 6.0;
  static const Color progressColor = Color(0xFFC084FC);
  static const Color backgroundColor = Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..repeat(reverse: true);

    _handleStartup();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      final authService = ref.read(authRefreshServiceProvider);
      final result = await authService.refreshToken(refreshToken);

      await local.saveTokens(result.accessToken, result.refreshToken);

      SocketService().connect(result.accessToken);

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
            const SizedBox(height: 30),
            Container(
              width: progressBarWidth,
              height: progressBarHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animationValue = _animationController.value;

                    const double segmentLength = 0.2;
                    final startPosition =
                        animationValue * (1.0 - segmentLength);

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: segmentLength,
                        child: Transform.translate(
                          offset: Offset(startPosition * progressBarWidth, 0),
                          child: Container(color: progressColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
