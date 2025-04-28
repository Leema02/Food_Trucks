import 'package:flutter/material.dart';
import 'package:myapp/core/constants/colors.dart';

class HomeFloatingButton extends StatelessWidget {
  const HomeFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.orangeColor,
      onPressed: () {
        // Action here
      },
      child: const Icon(Icons.star),
    );
  }
}
