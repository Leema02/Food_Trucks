import 'package:flutter/material.dart';

class CuisineGridSection extends StatelessWidget {
  const CuisineGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cuisines = [
      {"label": "Multi-Cuisine", "image": "assets/multi.jpg"},
      {"label": "American", "image": "assets/american.jpg"},
      {"label": "Asian", "image": "assets/asian.jpg"},
      {"label": "BBQ", "image": "assets/bbq.jpg"},
      {"label": "Brazilian", "image": "assets/brazilian.jpg"},
      {"label": "Breakfast", "image": "assets/breakfast.jpg"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Cuisine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cuisines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final cuisine = cuisines[index];
              return _buildCuisineTile(cuisine["label"]!, cuisine["image"]!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineTile(String label, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Container(color: Colors.black38),
          Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
