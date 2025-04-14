import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:myapp/core/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; // 👈 Make sure to pass this when navigating

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content: Center(
        heightFactor: 1.5,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showMessage("❌ Passwords do not match", isError: true);
        return;
      }

      final response = await AuthService.resetPassword(
        widget.email,
        _newPasswordController.text,
      );

      if (response.statusCode == 200) {
        _showMessage("✅ Password reset successful");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        _showMessage("❌ Failed to reset password", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Responsive(
          mobile: _buildForm(context, 20, double.infinity),
          tablet: _buildForm(context, 40, 500),
          desktop: _buildForm(context, 80, 600),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, double padding, double formWidth) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image/truckLogo.png', height: 100),
              const SizedBox(height: 20),
              SizedBox(
                width: formWidth,
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Reset Password",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildPasswordField(),
                        const SizedBox(height: 10),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 20),
                        AuthButton(
                          text: "Confirm",
                          onPressed: _handleResetPassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_showNewPassword,
      decoration: InputDecoration(
        hintText: "New Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon:
              Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter new password' : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        hintText: "Confirm Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(
              _showConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () =>
              setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please confirm password' : null,
    );
  }
}
