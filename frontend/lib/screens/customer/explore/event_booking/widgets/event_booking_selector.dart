import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/customer/explore/event_booking/truck_booking_screen.dart';

class EventBookingSelector extends StatefulWidget {
  const EventBookingSelector({super.key});

  @override
  State<EventBookingSelector> createState() => _EventBookingSelectorState();
}

class _EventBookingSelectorState extends State<EventBookingSelector> {
  List<dynamic> trucks = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    try {
      final data = await TruckOwnerService
          .getPublicTrucks(); // You can filter by city if needed
      setState(() {
        trucks = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return ListView.builder(
      itemCount: trucks.length,
      itemBuilder: (context, index) {
        final truck = trucks[index];
        return ListTile(
          leading: const Icon(Icons.food_bank),
          title: Text(truck['truck_name'] ?? 'Unnamed Truck'),
          subtitle: Text(truck['city'] ?? 'Unknown City'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TruckBookingScreen(truck: truck),
              ),
            );
          },
        );
      },
    );
  }
}
