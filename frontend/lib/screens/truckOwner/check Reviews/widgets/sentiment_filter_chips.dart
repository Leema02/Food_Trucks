import 'package:flutter/material.dart';

class SentimentFilterChips extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const SentimentFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sentiments = ['All', 'Positive', 'Neutral', 'Negative'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        children: sentiments.map((s) {
          final isSelected = selected == s;
          return InputChip(
            // Changed from ChoiceChip to InputChip
            label: Text(s),
            selected: isSelected,
            onSelected: (_) => onChanged(s),
            selectedColor: const Color.fromARGB(255, 168, 70, 255),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            showCheckmark: false, // Explicitly disable checkmark
          );
        }).toList(),
      ),
    );
  }
}
