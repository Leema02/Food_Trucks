import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';

class HeaderBar extends StatelessWidget {
  final bool useButton;
  final String? currentCityName;
  final VoidCallback onLocationTap;
  final VoidCallback onContactTap;

  const HeaderBar({
    super.key,
    required this.useButton,
    required this.currentCityName,
    required this.onLocationTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: Platform.isIOS ? 200 : 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangeColor, AppColors.orangeLightColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: Platform.isIOS
                  ? const EdgeInsets.only(top: 50.0, left: 20, right: 20)
                  : const EdgeInsets.only(top: 30.0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (useButton)
                    ElevatedButton.icon(
                      onPressed: onLocationTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orangeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      icon: const Icon(Icons.location_on),
                      label: const Text("Choose Location",
                          style: TextStyle(fontSize: 16)),
                    )
                  else
                    Text(
                      currentCityName ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 55.0, right: 8.0),
                    child: IconButton(
                      icon:
                          const Icon(Icons.phone_in_talk, color: Colors.white),
                      iconSize: 28,
                      onPressed: onContactTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
