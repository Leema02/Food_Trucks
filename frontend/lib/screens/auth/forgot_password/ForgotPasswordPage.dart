import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:myapp/screens/auth/forgot_password/ResetPasswordPage.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_text_fields.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (Responsive.isDesktop(context)) {
        _showPopup(context, 600);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Responsive(
          mobile: _buildNewPage(context, 20, double.infinity),
          tablet: _buildNewPage(context, 40, 500),
          desktop: _buildDesktop(context),
        ),
      ),
    );
  }

  Widget _buildNewPage(
      BuildContext context, double horizontalPadding, double formWidth) {
    return SingleChildScrollView(
      // ✅ Scroll on keyboard open
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image/truckLogo.png', height: 100),
              const SizedBox(height: 20),
              SizedBox(
                width: formWidth,
                child: AuthCard(
                  child: _buildForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/truckLogo.png', height: 120),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context, double formWidth) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SizedBox(
            width: formWidth,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildForm(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Reset Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter your email to receive a password reset link.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          AuthTextField(
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 15),
          AuthButton(
            text: 'Send Reset Link',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print("✅ Reset link sent to: ${_emailController.text}");
                Navigator.pop(context); // Close dialog if desktop
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordPage(),
                  ),
                );
              } else {
                print("❌ Invalid Email");
              }
            },
          ),
          const SizedBox(height: 10),
          AuthSwitchButton(
            text: "Back to Login",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
