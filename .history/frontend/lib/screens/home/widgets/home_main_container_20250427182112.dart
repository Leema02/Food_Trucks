import 'package:flutter/material.dart';
import 'package:myapp/core/constants/images.dart';
import 'package:myapp/screens/auth/widgets/card_widget.dart'; // 🔥 your original widget

class HomeMainContainer extends StatelessWidget {
  final String selectedLocation;

  const HomeMainContainer({super.key, required this.selectedLocation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Section Title - Featured Restaurants
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Featured Restaurants in $selectedLocation",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Horizontal scroll for Featured Restaurants
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CardWidget(
                title: "Cafe De Perks",
                imagePath: AppImages.restaurantPlaceholder,
              ),
              const SizedBox(width: 20),
              CardWidget(
                title: "Sunrise Dine",
                imagePath: AppImages.restaurantPlaceholder,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Section Title - More Restaurants
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "More Restaurants in $selectedLocation",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Horizontal scroll for More Restaurants
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CardWidget(
                title: "Fast Grill",
                imagePath: AppImages.restaurantPlaceholder,
              ),
              const SizedBox(width: 20),
              CardWidget(
                title: "Seafood House",
                imagePath: AppImages.restaurantPlaceholder,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
