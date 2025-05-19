import 'package:flutter/material.dart';

class CalendarTile extends StatelessWidget {
  final DateTime date;
  final bool isUnavailable;
  final VoidCallback onTap;

  const CalendarTile({
    super.key,
    required this.date,
    required this.isUnavailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateTime.now().toLocal().difference(date).inDays == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isUnavailable
              ? Colors.redAccent.withOpacity(0.6)
              : Colors.greenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnavailable ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
