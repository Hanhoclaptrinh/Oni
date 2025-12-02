import 'package:flutter/material.dart';
import 'package:frontend/data/models/SignupRequest.dart';
import 'package:frontend/data/services/AuthService.dart';
import 'package:frontend/data/services/LocalStorageService.dart';
import 'package:frontend/presentation/screens/MainScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // xử lý đăng ký
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final signupRequest = SignupRequest(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    try {
      final authService = AuthService();
      final authResult = await authService.signup(signupRequest);

      final localStorageService = LocalStorageService();
      localStorageService.saveToken(authResult.refreshToken);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký thành công',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
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
            'Đăng ký thất bại $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
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
            // first and last name
            Row(
              children: [
                // lastname
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    labelText: "Họ",
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                // firstname
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    labelText: "Tên",
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),

            // username
            _buildTextField(
              controller: _usernameController,
              labelText: "Username",
              icon: Icons.alternate_email,
            ),

            // email
            _buildTextField(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email_outlined,
              isEmail: true,
            ),

            // password
            _buildTextField(
              controller: _passwordController,
              labelText: "Mật khẩu",
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // register button
            ElevatedButton(
              onPressed: _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
              ),
              child: const Text(
                "ĐĂNG KÝ",
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

            // đăng ký bằng phương thức khác
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
              if (isEmail && !value.contains('@')) {
                return 'Email không hợp lệ';
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

  // đăng ký bằng phương thức khác
  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RawMaterialButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập bằng $label chưa được triển khai'),
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
