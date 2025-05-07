import 'package:flutter/material.dart';

class CityListSheet extends StatelessWidget {
  final Function(String) onCitySelected;
  final List<String> cities;

  const CityListSheet({
    super.key,
    required this.onCitySelected,
    this.cities = const [
      "Ramallah",
      "Nablus",
      "Hebron",
      "Bethlehem",
      "Jenin",
      "Tulkarm",
      "Qalqilya",
      "Salfit",
      "Tubas",
      "Jericho"
    ],
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
        ...cities.map((city) => ListTile(
              title: Text(city),
              trailing: const Icon(Icons.location_on, color: Colors.orange),
              onTap: () => onCitySelected(city),
            )),
      ],
    );
  }
}
