import 'package:flutter/material.dart';

class MessageLine extends StatelessWidget {
  const MessageLine({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  final String text;
  final bool isMe;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    final timeFormatted = timestamp != null
        ? "${timestamp!.hour.toString().padLeft(2, '0')}:${timestamp!.minute.toString().padLeft(2, '0')}"
        : '';

    return Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(20.0),
      color: isMe ? Colors.orange : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            if (timestamp != null && text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  timeFormatted,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}