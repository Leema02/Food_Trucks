import 'package:flutter/material.dart';

class LocationSelectorSheet extends StatelessWidget {
  final Widget currentLocationTile;
  final Widget exploreServiceAreasTile;

  const LocationSelectorSheet({
    super.key,
    required this.currentLocationTile,
    required this.exploreServiceAreasTile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Choose your location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          currentLocationTile,
          const Divider(height: 32, thickness: 1),
          exploreServiceAreasTile,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
