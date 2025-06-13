import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/home/widgets/truck_card.dart';

class CustomTruckListPage extends StatelessWidget {
  final String title;
  final List<dynamic> trucks;

  const CustomTruckListPage({
    super.key,
    required this.title,
    required this.trucks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: const Color(0xFFF8F8F8),
      body: trucks.isEmpty
          ? const Center(child: Text("No trucks found."))
          : ListView.builder(
              itemCount: trucks.length,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemBuilder: (context, index) {
                final truckData = Map<String, dynamic>.from(trucks[index]);
                truckData['menu_items'] = truckData['menu_items'] ?? [];

                return TruckCard(
                  truck: truckData,
                  activeSearchTerms: [title],
                );
              },
            ),
    );
  }
}
