import 'package:flutter/material.dart';
import 'package:frontend/data/models/SigninRequest.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';
import 'package:frontend/presentation/screens/MainScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // xử lý đăng nhập
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final signinRequest = SigninRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    try {
      final authService = AuthService();
      final authResult = await authService.signin(signinRequest);

      final localStorageService = LocalStorageService();
      await localStorageService.saveTokens(
        authResult.accessToken,
        authResult.refreshToken,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng nhập thành công',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng nhập thất bại',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // email
            _buildTextField(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email_outlined,
              isEmail: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email không hợp lệ';
                }
                if (!value.contains("@")) {
                  return "Email không hợp lệ";
                }
                return null;
              },
            ),

            // password
            _buildTextField(
              controller: _passwordController,
              labelText: "Mật khẩu",
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mật khẩu không hợp lệ';
                }
                return null;
              },
            ),

            // quên mật khẩu
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Chức năng Quên mật khẩu chưa được triển khai.',
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // login button
            ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
              ),
              child: const Text(
                "ĐĂNG NHẬP",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // divider
            const Row(
              children: <Widget>[
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("HOẶC", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 20),

            // đăng nhập bằng phương thức khác
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton("Google", Icons.g_mobiledata, Colors.red),
                _buildSocialButton("Facebook", Icons.facebook, Colors.blue),
                _buildSocialButton("Apple", Icons.apple, Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập $labelText';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 10.0,
          ),
        ),
      ),
    );
  }

  // phương thức đăng nhập khác
  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RawMaterialButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập bằng $label chưa được triển khai.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        elevation: 3.0,
        fillColor: color,
        padding: const EdgeInsets.all(15.0),
        shape: const CircleBorder(),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
