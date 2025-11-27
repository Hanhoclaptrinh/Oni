import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/SignInScreen.dart';
import 'package:frontend/presentation/screens/SignUpScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // app name
                  Text(
                    "Oni Chat",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 12),

                  // app logo
                  Image.asset(
                    "assets/images/logo.png",
                    height: 150,
                    width: 150,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // button switch
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _animateTo(0),
                    child: Column(
                      children: [
                        Text(
                          "Sign In",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _pageIndex == 0 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          height: 3,
                          width: _pageIndex == 0 ? 40 : 0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _animateTo(1),
                    child: Column(
                      children: [
                        Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _pageIndex == 1 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          height: 3,
                          width: _pageIndex == 1 ? 40 : 0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // pageview
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                children: [
                  // sign in
                  SignInScreen(),
                  // sign up
                  SignUpScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // tab button
  Widget _tabButton(String label, int index) {
    final bool active = _pageIndex == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: active ? 40 : 0,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
