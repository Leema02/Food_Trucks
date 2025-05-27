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

  String formatDateRange(Map b) {
    try {
      final startDate = DateTime.tryParse(b['event_start_date'] ?? '');
      final endDate = DateTime.tryParse(b['event_end_date'] ?? '');
      final startTime = b['start_time'] ?? '';
      final endTime = b['end_time'] ?? '';
      if (startDate == null || endDate == null) return "Unknown date";

      final formattedStartDate = DateFormat('MMM d, yyyy').format(startDate);
      final formattedEndDate = DateFormat('MMM d, yyyy').format(endDate);
      return "$formattedStartDate • $startTime → $formattedEndDate • $endTime";
    } catch (_) {
      return "Unknown date";
    }
  }

  List<dynamic> get filteredBookings {
    if (selectedFilter == 'ALL') return bookings;
    return bookings
        .where((b) =>
            (b['status'] ?? '').toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }

  Widget _buildFilterChips() {
    final filters = ['ALL', 'PENDING', 'CONFIRMED', 'REJECTED'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        children: filters.map((status) {
          final isSelected = selectedFilter == status;
          return ChoiceChip(
            label: Text(status),
            selected: isSelected,
            selectedColor: Colors.orange,
            onSelected: (_) {
              setState(() => selectedFilter = status);
            },
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.orange),
            ),
            backgroundColor: Colors.transparent,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return Column(
      children: [
        _buildFilterChips(),
        const Divider(height: 1),
        Expanded(
          child: filteredBookings.isEmpty
              ? const Center(child: Text("No bookings match this status."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = filteredBookings[index];
                    final truck = b['truck_id'];
                    final truckName = truck['truck_name'] ?? 'Unnamed Truck';
                    final city = truck['city'] ?? 'Unknown City';
                    final dateTime = formatDateRange(b);
                    final status =
                        (b['status'] ?? 'pending').toString().toUpperCase();
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text("City: $city"),
                          Text("Date: $dateTime"),
                          if (status == 'CONFIRMED' && totalAmount != null)
                            Text("Total Amount: ₪$totalAmount",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (status == 'PENDING')
                                IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.red),
                                  tooltip: 'Cancel Booking',
                                  onPressed: () => confirmDelete(b['_id']),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
