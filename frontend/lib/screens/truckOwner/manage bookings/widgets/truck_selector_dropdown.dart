import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TruckSelectorDropdown extends StatelessWidget {
  final List<dynamic> trucks;
  final String? selectedTruckId;
  final Function(String?) onChanged;

  const TruckSelectorDropdown({
    super.key,
    required this.trucks,
    required this.selectedTruckId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: selectedTruckId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: "select_a_truck".tr(),
          border: const OutlineInputBorder(),
        ),
        items: trucks.map<DropdownMenuItem<String>>((truck) {
          return DropdownMenuItem<String>(
            value: truck['_id'],
            child: Text(truck['truck_name'] ?? "unnamed_truck".tr()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
