import 'package:flutter/material.dart';

class EndDrawer extends StatelessWidget {
  final BuildContext parentContext;

  const EndDrawer({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 300, right: 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🛒 Cart Button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Cart page
                  },
                  icon: const Icon(Icons.shopping_cart, color: Colors.orange),
                  iconSize: 30,
                ),
                const Divider(height: 1),

                // 👤 Profile Button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Profile page
                  },
                  icon: const Icon(Icons.person, color: Colors.orange),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
