import 'package:flutter/material.dart';

class BookingFilterChips extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;

  const BookingFilterChips(
      {super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filters = ['ALL', 'PENDING', 'CONFIRMED', 'REJECTED'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        children: filters.map((status) {
          final isSelected = selected == status;
          return ChoiceChip(
            label: Text(status),
            selected: isSelected,
            selectedColor: Colors.orange,
            onSelected: (_) => onSelect(status),
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
}
