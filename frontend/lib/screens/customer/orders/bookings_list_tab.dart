import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/orders/widgets/customer_booking_card.dart';
import 'package:myapp/screens/customer/orders/widgets/filter_chips.dart';
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
  String selectedFilter = 'ALL';

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
            backgroundColor: Colors.red),
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
              onPressed: () => Navigator.pop(context), child: const Text("No")),
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

  List<dynamic> get filteredBookings {
    if (selectedFilter == 'ALL') return bookings;
    return bookings.where((b) {
      final status = (b['status'] ?? '').toString().toUpperCase();
      return status == selectedFilter;
    }).toList();
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

    return Column(
      children: [
        BookingFilterChips(
          selected: selectedFilter,
          onSelect: (status) => setState(() => selectedFilter = status),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredBookings.isEmpty
              ? const Center(child: Text("No bookings match this status."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return BookingCard(
                      booking: booking,
                      onDelete: () => confirmDelete(booking['_id']),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
