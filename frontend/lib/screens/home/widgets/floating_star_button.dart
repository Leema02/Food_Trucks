import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/core/constants/colors.dart';

class FloatingStarButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingStarButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orangeColor,
              AppColors.orangeLightColor.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.orangeColor,
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          FontAwesomeIcons.solidStar,
          size: 26,
          color: Colors.white,
        ),
      ),
    );
  }
}
