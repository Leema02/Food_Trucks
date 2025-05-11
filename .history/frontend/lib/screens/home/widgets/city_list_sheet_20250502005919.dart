import 'package:flutter/material.dart';

class CityListSheet extends StatelessWidget {
  final List<String> cities;
  final Function(String) onCitySelected;

  const CityListSheet({
    super.key,
    required this.cities,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Select a city:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...cities.map(
          (cityName) => ListTile(
            title: Text(cityName),
            trailing: const Icon(Icons.location_on, color: Colors.orange),
            onTap: () {
              Navigator.pop(context);
              onCitySelected(cityName);
            },
          ),
        ),
      ],
    );
  }
}
