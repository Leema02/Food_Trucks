import 'package:flutter/material.dart';

class CalendarTile extends StatelessWidget {
  final DateTime date;
  final bool isUnavailable;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const CalendarTile({
    super.key,
    required this.date,
    required this.isUnavailable,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.black;

    if (isUnavailable) {
      backgroundColor = Colors.redAccent.withOpacity(0.8);
      textColor = Colors.white;
    } else if (isSelected) {
      backgroundColor = Colors.green.shade400;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Colors.blue.shade100;
    } else {
      backgroundColor = Colors.grey.shade100;
    }

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}
