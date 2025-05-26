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
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: Color.fromARGB(255, 244, 155, 54),
              child: Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/chatbot');
            },
          ),
        ],
      ),
    );
  }
}
