import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StatusFilterChips extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ['pending', 'confirmed', 'rejected'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        children: statuses.map((status) {
          final isSelected = selectedStatus == status;
          final selectedColor = {
            'pending': Colors.orange.shade200,
            'confirmed': Colors.green.shade200,
            'rejected': Colors.red.shade200,
          }[status];

          return ChoiceChip(
            label: Text(status.tr()),
            selected: isSelected,
            selectedColor: selectedColor,
            onSelected: (_) => onStatusChanged(status),
          );
        }).toList(),
      ),
    );
  }
}
