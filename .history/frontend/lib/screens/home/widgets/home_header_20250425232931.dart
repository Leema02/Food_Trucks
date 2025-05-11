import 'package:flutter/material.dart';
import 'package:myapp/core/constants/colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      color: AppColors.orangeColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Welcome Back!',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          Icon(Icons.account_circle, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}
