// lib/screens/home/widgets/city_list_sheet.dart
import 'package:flutter/material.dart';

final List<String> supportedCities = [
  "Ramallah",
  "Nablus",
  "Bethlehem",
  "Hebron",
  "Jericho",
  "Tulkarm",
  "Jenin",
  "Qalqilya",
  "Salfit",
  "Tubas"
];

class CityListSheet extends StatelessWidget {
  final void Function(String cityName) onCitySelected;

  const CityListSheet(
      {super.key, required this.onCitySelected, required List cities});

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
        ...supportedCities.map((city) => ListTile(
              title: Text(city),
              trailing: const Icon(Icons.location_on, color: Colors.orange),
              onTap: () => onCitySelected(city),
            )),
      ],
    );
  }
}
