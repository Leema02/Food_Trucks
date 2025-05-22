import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/event_booking_service.dart';

class BookingsListTab extends StatefulWidget {
  const BookingsListTab({super.key});

  @override
  State<BookingsListTab> createState() => _BookingsListTabState();
}

class _BookingsListTabState extends State<BookingsListTab> {
  List<dynamic> bookings = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final result = await EventBookingService.getMyBookings();
      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '❌ Error loading bookings: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (bookings.isEmpty) {
      return const Center(child: Text("You have no event bookings."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final truck = b['truck_id'];
        final truckName = truck['truck_name'] ?? 'Unnamed Truck';
        final city = truck['city'] ?? 'Unknown City';
        final date = formatDate(b['event_date']);
        final time = b['event_time'] ?? '';
        final status = (b['status'] ?? 'pending').toString().toUpperCase();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(truckName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("City: $city"),
              Text("Date: $date at $time"),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'CONFIRMED'
                          ? Colors.green
                          : status == 'REJECTED'
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
