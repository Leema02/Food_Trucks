import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/customer/home/home.dart';
import 'package:myapp/screens/truckOwner/ownerDashbored.dart';
import 'package:myapp/screens/auth/signup/signup.dart';
import 'package:myapp/screens/auth/forgot_password/ForgotPasswordPage.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/sign_up_bar.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';
import 'package:myapp/core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red[400] : Colors.green[400],
      content: Center(
        heightFactor: 1.5,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final credentials = {
        "email_address": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      };

      final httpResponse = await AuthService.login(credentials);
      final responseData = jsonDecode(httpResponse.body);

      if (httpResponse.statusCode == 200) {
        _showMessage("✅ Login successful");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);

        // Get user role from response
        String role = responseData['user']['role_id'];

        // Navigate based on role
        if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (role == 'truck owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const TruckOwnerDashboard()),
          );
        } else {
          _showMessage("❌ Unknown role. Contact support.", isError: true);
        }
      } else {
        _showMessage("❌ ${responseData['message']}", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Responsive(
          mobile: _buildForm(context, 20, double.infinity, true, true),
          tablet: _buildForm(context, 40, 500, true, false),
          desktop: _buildForm(context, 80, 600, false, false),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, double horizontalPadding,
      double formWidth, bool isMobile, bool scrollEnabled) {
    final formContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (!isMobile)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 150, top: 180),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset('assets/image/truckLogo.png', height: 300),
                ),
              ),
            ),
          Expanded(
            flex: isMobile ? 1 : 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  Image.asset('assets/image/truckLogo.png', height: 120),
                SizedBox(
                  width: formWidth,
                  child: AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SignUpBar(isLoginPage: true),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration("Email"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: _inputDecoration(
                              "Password",
                              suffixIcon: _buildPasswordToggle(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter the password'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          AuthSwitchButton(
                            text: "Forgot Password?",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AuthButton(
                            text: 'Log In',
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 10),
                          AuthSwitchButton(
                            text: "Don't have an account? Sign Up",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );

    return scrollEnabled
        ? SingleChildScrollView(child: formContent)
        : formContent;
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepOrange),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      icon: Icon(
        _showPassword ? Icons.visibility : Icons.visibility_off,
      ),
      onPressed: () => setState(() => _showPassword = !_showPassword),
    );
  }
}
