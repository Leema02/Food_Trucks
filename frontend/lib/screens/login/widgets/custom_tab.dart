import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected; // To indicate active tab

  const CustomTab({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.orange : Colors.white, // Active Tab color
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.orange, // Active Tab Text Color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
