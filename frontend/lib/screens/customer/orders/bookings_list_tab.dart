import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  Future<void> deleteBooking(String bookingId) async {
    try {
      await EventBookingService.deleteBooking(bookingId);
      fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmDelete(String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteBooking(bookingId);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String isoDate, String time) {
    try {
      final combined = DateFormat("yyyy-MM-dd HH:mm").parse("$isoDate $time");
      return DateFormat('MMM d, yyyy • h:mm a').format(combined);
    } catch (_) {
      return "$isoDate at $time";
    }
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
        final dateTime = formatDateTime(b['event_date'], b['event_time'] ?? '');
        final rawStatus = b['status'] ?? 'pending';
        final status = rawStatus.toString().toUpperCase();
        final totalAmount = b['total_amount']?.toString();

        final statusColor = {
              'CONFIRMED': Colors.green,
              'REJECTED': Colors.red,
              'PENDING': Colors.orange,
            }[status] ??
            Colors.orange;

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
              Text(
                truckName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text("City: $city"),
              Text("Date: $dateTime"),
              if (status == 'CONFIRMED' && totalAmount != null)
                Text("Total Amount: ₪$totalAmount",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                  if (status == 'PENDING')
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'Cancel Booking',
                      onPressed: () => confirmDelete(b['_id']),
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
