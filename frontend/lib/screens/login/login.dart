import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home.dart';
import 'package:myapp/screens/signup/signup.dart';
import 'package:myapp/screens/forgot_password/ForgotPasswordPage.dart';
import 'package:myapp/screens/login/widgets/auth_background.dart';
import 'package:myapp/screens/login/widgets/auth_card.dart';
import 'package:myapp/screens/login/widgets/auth_text_fields.dart';
import 'package:myapp/screens/login/widgets/auth_buttons.dart';
import 'package:myapp/screens/login/widgets/sign_up_bar.dart';
import 'package:myapp/screens/login/widgets/responsive.dart';

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
    Widget formContent = Padding(
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
                  child: Image.asset(
                    'assets/image/truckLogo.png',
                    height: 300,
                  ),
                ),
              ),
            ),
          Expanded(
            flex: isMobile ? 1 : 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  Image.asset(
                    'assets/image/truckLogo.png',
                    height: 100,
                  ),
                SizedBox(
                  width: formWidth,
                  child: AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SignUpBar(isLoginPage: true),
                          const SizedBox(height: 15),
                          AuthTextField(
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 10),

                          /// Updated password field with visibility toggle
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.deepOrange),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                              ),
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
                                    const ForgotPasswordPage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AuthButton(
                            text: 'Log In',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                print("✅ Form Submitted Successfully");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );
                              } else {
                                print("❌ Form has errors");
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          AuthSwitchButton(
                            text: "Don't have an account? Sign Up",
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
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
}
