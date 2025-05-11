import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/customer_main_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/truckOwner/ownerDashbored.dart';
import 'package:myapp/screens/auth/signup/signup.dart';
import 'package:myapp/screens/auth/forgot_password/ForgotPasswordPage.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/auth/widgets/auth_card.dart';
import 'package:myapp/screens/auth/widgets/auth_buttons.dart';
import 'package:myapp/screens/auth/widgets/sign_up_bar.dart';
import 'package:myapp/screens/auth/widgets/responsive.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  final Locale? locale;
  const LoginPage({super.key, this.locale});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      _emailController.text = prefs.getString('saved_email') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      setState(() => _rememberMe = true);
    }
  }

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

        if (_rememberMe) {
          await prefs.setString('saved_email', _emailController.text);
          await prefs.setString('saved_password', _passwordController.text);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('saved_email');
          await prefs.remove('saved_password');
          await prefs.setBool('remember_me', false);
        }

        String role = responseData['user']['role_id'];
        if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const CustomerMainContainer()),
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
      body: Stack(
        children: [
          AuthBackground(
            child: Responsive(
              mobile: _buildForm(context, 20, double.infinity, true, true),
              tablet: _buildForm(context, 40, 500, true, false),
              desktop: _buildForm(context, 80, 600, false, false),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: PopupMenuButton<Locale>(
              icon: const Icon(Icons.language, color: Colors.black),
              onSelected: (locale) => context.setLocale(locale),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const PopupMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
              ],
            ),
          ),
        ],
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
                            decoration: _inputDecoration("email".tr()),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'pleaseenteremail'.tr();
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'pleaseentervalidemail'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: _inputDecoration("password".tr(),
                                suffixIcon: _buildPasswordToggle()),
                            validator: (value) => value == null || value.isEmpty
                                ? 'pleaseenterpassword'.tr()
                                : null,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                    () => _rememberMe = value ?? false),
                              ),
                              Text('rememberme'.tr()),
                            ],
                          ),
                          AuthSwitchButton(
                            text: "forgotpassword".tr(),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AuthButton(
                            text: "login".tr(),
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 10),
                          AuthSwitchButton(
                            text: "donthaveanaccount".tr(),
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
      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
      onPressed: () => setState(() => _showPassword = !_showPassword),
    );
  }
}
