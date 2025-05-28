import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const BookingCard({
    super.key,
    required this.booking,
    this.onApprove,
    this.onReject,
  });

  List<String> getDailySchedule(BuildContext context) {
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
    final customer = booking['user_id'];
    final guests = booking['guest_count']?.toString() ?? '0';
    final totalAmount = booking['total_amount'];
    final status = booking['status'];

    final startDate = DateTime.tryParse(booking['event_start_date'] ?? '');
    final endDate = DateTime.tryParse(booking['event_end_date'] ?? '');
    final duration = (startDate != null && endDate != null)
        ? "${endDate.difference(startDate).inDays + 1} ${'days'.tr()}"
        : "N/A";

    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${'duration'.tr()}: $duration",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...getDailySchedule(context).map((line) => Text(line)),
                  const SizedBox(height: 6),
                  Text("${'guests'.tr()}: $guests"),
                  Text(
                      "${'customer'.tr()}: ${customer['F_name']} ${customer['L_name']}"),
                  Text("${'email'.tr()}: ${customer['email_address']}"),
                  Text("${'phone'.tr()}: ${customer['phone_num'] ?? 'N/A'}"),
                  if (totalAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        "₪${totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isConfirmed
                              ? Colors.green
                              : isPending
                                  ? Colors.orange
                                  : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isPending
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'approve'.tr(),
                        onPressed: onApprove,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'reject'.tr(),
                        onPressed: onReject,
                      ),
                    ],
                  )
                : const Icon(Icons.info_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
