import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String city;
  final List<String> supportedCities;
  final Function(String) onCityChange;

  const HeaderSection({
    super.key,
    required this.city,
    required this.supportedCities,
    required this.onCityChange,
  });

  void _showCitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: supportedCities.map((c) {
          return ListTile(
            title: Text(c),
            trailing: c == city
                ? const Icon(Icons.check, color: Colors.orange)
                : null,
            onTap: () {
              onCityChange(c);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showCitySelector(context),
            icon: const Icon(Icons.location_on, size: 18),
            label: Text(city),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.orange),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Call us feature coming soon")),
              );
            },
          ),
        ],
      ),
    );
  }
}
