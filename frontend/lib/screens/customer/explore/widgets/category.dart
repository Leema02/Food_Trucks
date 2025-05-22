import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  final List<Map<String, String>> categories = const [
    {"title": "Multi-Cuisine", "image": "https://i.imgur.com/vD1rjZG.jpg"},
    {"title": "American", "image": "https://i.imgur.com/KJg4u2P.jpg"},
    {"title": "Asian", "image": "https://i.imgur.com/0HjVeqA.jpg"},
    {"title": "BBQ", "image": "https://i.imgur.com/hRQ6DGF.jpg"},
    {"title": "Brazilian", "image": "https://i.imgur.com/kxUXiuh.jpg"},
    {"title": "Breakfast", "image": "https://i.imgur.com/3R7bx3o.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(category["image"]!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Text(
              category["title"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
