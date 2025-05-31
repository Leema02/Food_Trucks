import 'package:flutter/material.dart';

class PopularSearchesSection extends StatelessWidget {
  const PopularSearchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Popular Searches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _searchTile("Open Now", Colors.red),
              _searchTile("Highest Rated", Colors.pink),
              _searchTile("Featured", Colors.deepOrange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchTile(String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.85),
      ),
      child: Center(
        child: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
