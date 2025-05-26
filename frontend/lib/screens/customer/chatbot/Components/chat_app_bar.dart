import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("ChatBot Assistant"),
      backgroundColor: Colors.orange,
      elevation: 1.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}