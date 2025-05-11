import 'package:flutter/material.dart';

class HomeMainContainer extends StatelessWidget {
  final String selectedLocation;

  const HomeMainContainer({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🧡 Show the location name at the top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            selectedLocation.isNotEmpty
                ? selectedLocation
                : 'Loading location...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ✅ Expanded makes ListView properly take the remaining height
        Expanded(
          child: ListView.builder(
            itemCount: 10, // example items
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Food Truck Item #$index'),
                  subtitle: Text('Location: $selectedLocation'),
                  leading: const Icon(Icons.fastfood, color: Colors.orange),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
