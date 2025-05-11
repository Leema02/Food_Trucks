import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:myapp/screens/auth/signup/signup.dart';
import 'package:myapp/screens/auth/widgets/custom_tab.dart';

class SignUpBar extends StatelessWidget {
  final bool isLoginPage; // To check which page is active

  const SignUpBar({super.key, required this.isLoginPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        borderRadius: BorderRadius.circular(25),
      ),
      height: 45,
      child: Row(
        children: [
          CustomTab(
            text: "login".tr(),
            isSelected: isLoginPage, // Active if on Login Page
            onPressed: isLoginPage
                ? () {} // Provide an empty function instead of null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
          ),
          CustomTab(
            text: "Sign Up",
            isSelected: !isLoginPage, // Active if on Sign-Up Page
            onPressed: !isLoginPage
                ? () {} // Provide an empty function instead of null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
