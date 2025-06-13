import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/home/widgets/truck_card.dart';
import 'package:intl/intl.dart';

class OpenNowPage extends StatelessWidget {
  final List<dynamic> allTrucks;

  const OpenNowPage({super.key, required this.allTrucks});

  bool isTruckOpen(String? openTimeStr, String? closeTimeStr) {
    if (openTimeStr == null || closeTimeStr == null) return false;

    try {
      final now = DateTime.now();

      final open = DateFormat("hh:mm a").parse(openTimeStr);
      final close = DateFormat("hh:mm a").parse(closeTimeStr);

      final openTime =
          DateTime(now.year, now.month, now.day, open.hour, open.minute);
      DateTime closeTime =
          DateTime(now.year, now.month, now.day, close.hour, close.minute);

      if (closeTime.isBefore(openTime)) {
        closeTime = closeTime.add(const Duration(days: 1));
      }

      return now.isAfter(openTime) && now.isBefore(closeTime);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final openNowTrucks = allTrucks.where((truck) {
      return isTruckOpen(
        truck['operating_hours']?['open'],
        truck['operating_hours']?['close'],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Now"),
      ),
      body: openNowTrucks.isEmpty
          ? const Center(child: Text("No food trucks are currently open."))
          : ListView.builder(
              itemCount: openNowTrucks.length,
              itemBuilder: (context, index) {
                return TruckCard(
                  truck: openNowTrucks[index],
                  activeSearchTerms: const [],
                );
              },
            ),
    );
  }
}
