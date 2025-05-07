import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';

class HeaderStack extends StatelessWidget {
  final String selectedLocation;
  final bool useButton;
  final VoidCallback onLocationPressed;
  final VoidCallback onFilterPressed;

  const HeaderStack({
    super.key,
    required this.selectedLocation,
    required this.useButton,
    required this.onLocationPressed,
    required this.onFilterPressed,
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
                  useButton
                      ? ElevatedButton.icon(
                          onPressed: onLocationPressed,
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
                          label: Text(
                            selectedLocation,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : Text(
                          selectedLocation,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: onFilterPressed,
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
