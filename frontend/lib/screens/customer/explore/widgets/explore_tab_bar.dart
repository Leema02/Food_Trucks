import 'package:flutter/material.dart';

class ExploreTabBar extends StatelessWidget {
  const ExploreTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelColor: Colors.deepOrange,
      unselectedLabelColor: Colors.black54,
      indicatorColor: Colors.deepOrange,
      tabs: const [
        Tab(text: 'Food Trucks'),
        Tab(text: 'Event Booking'),
      ],
    );
  }
}
