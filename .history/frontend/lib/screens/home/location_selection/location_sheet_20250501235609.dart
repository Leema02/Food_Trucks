import 'package:flutter/material.dart';

class LocationSelectionSheet extends StatelessWidget {
  final VoidCallback onCurrentLocationPressed;
  final VoidCallback onExploreAreasPressed;

  const LocationSelectionSheet({
    super.key,
    required this.onCurrentLocationPressed,
    required this.onExploreAreasPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Choose your location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildCurrentLocationTile(),
          const Divider(height: 32, thickness: 1),
          _buildExploreServiceAreasTile(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.my_location, color: Colors.red),
      ),
      title: const Text(
        "Current location",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Move to your current location"),
      trailing: const Icon(Icons.check_circle, color: Colors.red),
      onTap: onCurrentLocationPressed,
    );
  }

  Widget _buildExploreServiceAreasTile() {
    return ListTile(
      leading: const Icon(Icons.location_city, color: Colors.black),
      title: const Text(
        "Explore our service areas",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("See where we're operating"),
      onTap: onExploreAreasPressed,
    );
  }
}
