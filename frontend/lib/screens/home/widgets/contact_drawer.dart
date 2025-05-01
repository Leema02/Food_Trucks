import 'package:flutter/material.dart';

class ContactDrawer extends StatelessWidget {
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;

  const ContactDrawer(
      {super.key, required this.onCallTap, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 65,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconBox(Icons.phone, const Color(0xFFFFA726), onCallTap),
            _buildIconBox(Icons.chat, const Color(0xFFFFCC80), onChatTap),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: icon == Icons.phone
                ? const BorderRadius.only(topLeft: Radius.circular(16))
                : const BorderRadius.only(bottomLeft: Radius.circular(16)),
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 26)),
        ),
      ),
    );
  }
}
