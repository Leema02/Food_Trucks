import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final Map booking;
  final VoidCallback? onDelete;

  const BookingCard({super.key, required this.booking, this.onDelete});

  List<String> getDailyBreakdown() {
    final startDate = DateTime.tryParse(booking['event_start_date'] ?? '');
    final endDate = DateTime.tryParse(booking['event_end_date'] ?? '');
    final startTime = booking['start_time'];
    final endTime = booking['end_time'];

    if (startDate == null ||
        endDate == null ||
        startTime == null ||
        endTime == null) {
      return [];
    }

    final entries = <String>[];
    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      final dateStr = DateFormat('MMM d, yyyy').format(current);
      entries.add("🕒 $dateStr: $startTime → $endTime");
      current = current.add(const Duration(days: 1));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final truck = booking['truck_id'];
    final truckName = truck['truck_name'] ?? 'Unnamed Truck';
    final city = truck['city'] ?? 'Unknown City';
    final status = (booking['status'] ?? 'PENDING').toString().toUpperCase();
    final totalAmount = booking['total_amount'];
    final statusColor = {
          'CONFIRMED': Colors.green,
          'REJECTED': Colors.red,
          'PENDING': Colors.orange,
        }[status] ??
        Colors.grey;

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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text("City: $city"),
          const SizedBox(height: 4),
          ...getDailyBreakdown().map((line) => Text(line)),
          if (totalAmount != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                status == 'CONFIRMED'
                    ? "Total Amount: ₪${totalAmount.toStringAsFixed(2)}"
                    : "Estimated Total: ₪${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: status == 'CONFIRMED'
                      ? Colors.green
                      : Colors.orange.shade800,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  Text("Status: $status",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              if (status == 'PENDING')
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'Cancel Booking',
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
