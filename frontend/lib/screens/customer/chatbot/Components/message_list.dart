import 'package:flutter/material.dart';
import 'MessageLine.dart';

class MessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No messages yet."),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[messages.length - 1 - index];
          final isMe = message['sender'] == 'user';
          final text = message['text'] as String;
          final timestamp = message['timestamp'] as DateTime?;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: MessageLine(
                    text: text,
                    isMe: isMe,
                    timestamp: timestamp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}