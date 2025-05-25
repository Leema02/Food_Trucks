import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/chat_app_bar.dart';
import 'components/message_list.dart';
import 'components/message_input_bar.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'bot',
      'text': "👋 Hi! Ask me anything about your orders or trucks.",
      'timestamp': DateTime.now().subtract(const Duration(seconds: 1)),
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: const ChatAppBar(),
      body: Column(
        children: [
          MessageList(
            messages: messages,
            scrollController: _scrollController,
          ),
          MessageInputBar(
            controller: messageTextController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final messageText = messageTextController.text.trim();
    if (messageText.isNotEmpty) {
      if (mounted) {
        setState(() {
          messages.add({
            'sender': 'user',
            'text': messageText,
            'timestamp': DateTime.now(),
          });
        });
      }

      messageTextController.clear();
      _scrollToBottom();

      final botResponse = await _sendMessageToAPI(messageText);
      if (mounted) {
        setState(() {
          messages.add({
            'sender': 'bot',
            'text': botResponse ?? "Sorry, I couldn't get a response right now.",
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && messages.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<String?> _sendMessageToAPI(String message) async {
    const apiKey = 'AIzaSyCsfzNXk_nP9V5my0gqNc5wV0-kPcPZ9YU';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return content ?? 'Received no text from Gemini.';
      } else {
        return 'Error ${response.statusCode}: Could not fetch response.';
      }
    } catch (e) {
      return 'Failed to connect to the chat service.';
    }
  }
}