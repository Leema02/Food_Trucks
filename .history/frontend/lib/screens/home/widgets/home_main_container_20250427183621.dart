import 'package:flutter/material.dart';

class HomeMainContainer extends StatelessWidget {
  final String selectedLocation;

  const HomeMainContainer({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔥 Display the selected location at the top
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

        // 👇 Here you can continue adding the other parts of your List View
        Expanded(
          child: ListView.builder(
            itemCount: 10, // example
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Sample Food Truck Item #$index'),
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
