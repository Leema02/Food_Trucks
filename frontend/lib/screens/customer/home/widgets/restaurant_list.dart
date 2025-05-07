import 'package:flutter/material.dart';

class RestaurantList extends StatelessWidget {
  const RestaurantList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Restaurants go here...'), // Replace with your real data/widget
      ],
    );
  }
}
