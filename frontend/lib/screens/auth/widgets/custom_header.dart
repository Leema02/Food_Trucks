// ✅ custom_header.dart
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final int quantity;
  final bool internalScreen;

  const CustomHeader({
    super.key,
    required this.title,
    required this.quantity,
    required this.internalScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(
              quantity.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
