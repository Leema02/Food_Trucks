import 'package:flutter/material.dart';
import 'dart:io'; // Add this import for Platform
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';

class HomeHeader extends StatelessWidget {
  final String? city;
  final VoidCallback onLocationPressed;
  final VoidCallback onMenuPressed;
  final bool showLocationButton;

  const HomeHeader({
    super.key,
    required this.city,
    required this.onLocationPressed,
    required this.onMenuPressed,
    required this.showLocationButton,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShapeClipper(),
      child: Container(
        height: Platform.isIOS ? 200 : 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.orangeColor, AppColors.orangeLightColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: Platform.isIOS
                ? const EdgeInsets.only(top: 20.0, left: 20, right: 20)
                : const EdgeInsets.only(top: 10.0, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLocationButton)
                      _buildLocationButton()
                    else
                      _buildCityName(),
                    _buildMenuButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return ElevatedButton(
      onPressed: onLocationPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.orangeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 20),
          const SizedBox(width: 8),
          const Text(
            "Choose Location",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCityName() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Text(
        city ?? 'Select Location',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMenuButton() {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: IconButton(
        icon: const Icon(Icons.phone_in_talk, color: Colors.white, size: 28),
        onPressed: onMenuPressed,
        padding: EdgeInsets.zero, // Fix padding error
      ),
    );
  }
}
