import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:myapp/screens/auth/forgot_password/ResetPasswordPage.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _codeSent = false;
  bool _verifyingCode = false;

  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red[400] : Colors.green[400],
      content: Center(
        heightFactor: 1.5,
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();
    final response = await AuthService.forgotPassword({"email_address": email});
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() => _codeSent = true);
      _showMessage("✅ ${responseData['message']}");
    } else {
      _showMessage("❌ ${responseData['message']}", isError: true);
    }
  }

  void _verifyCodeAndProceed() async {
    setState(() => _verifyingCode = true);

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final response = await AuthService.verifyResetCode({
      "email_address": email,
      "code": code,
    });

    final responseData = jsonDecode(response.body);
    setState(() => _verifyingCode = false);

    if (response.statusCode == 200) {
      _showMessage("✅ Code verified!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ),
      );
    } else {
      _showMessage("❌ ${responseData['message']}", isError: true);
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
                      children: [
                        Text(
                          "resetpassword".tr(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "enteryouremail".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "email".tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.deepOrange),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        AuthButton(
                          text: _codeSent ? "resendcode".tr() : "sendcode".tr(),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _sendResetCode();
                            }
                          },
                        ),
                        if (_codeSent) ...[
                          const SizedBox(height: 15),
                          const Text(
                            "Enter the 4-digit code sent to your email",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              hintText: "4digitcode".tr(),
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AuthButton(
                            text: _verifyingCode
                                ? "verifiying".tr()
                                : "verifycode".tr(),
                            onPressed: _verifyingCode
                                ? () {}
                                : () => _verifyCodeAndProceed(),
                          ),
                        ],
                        const SizedBox(height: 10),
                        AuthSwitchButton(
                          text: "backtologin".tr(),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          ),
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
}
