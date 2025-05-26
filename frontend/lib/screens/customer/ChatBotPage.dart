import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');

  @override
  void initState() {
    super.initState();
    _addBotMessage("👋 Hi! Ask me anything about your orders or trucks.");
  }

  void _addBotMessage(String text) {
    final botMsg = types.TextMessage(
      author: _bot,
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() => _messages.insert(0, botMsg));
  }

  void _handleSendPressed(types.PartialText message) {
    final userMsg = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() => _messages.insert(0, userMsg));

    _handleBotReply(message.text.toLowerCase());
  }

  void _handleBotReply(String input) {
    if (input.contains('hi') || input.contains('hello')) {
      _addBotMessage("Hello! 😊 How can I help you?");
    } else if (input.contains('order')) {
      _addBotMessage(
          "🧾 You can view your current order status under the Orders tab.");
    } else if (input.contains('truck')) {
      _addBotMessage(
          "🚚 You can explore available trucks under the Explore tab.");
    } else if (input.contains('menu')) {
      _addBotMessage("📋 You can view a truck’s menu by tapping on it.");
    } else {
      _addBotMessage(
          "🤖 Sorry, I didn’t understand that. Try asking about orders or trucks.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Light background
      appBar: AppBar(
        title: const Text("ChatBot Assistant"),
        backgroundColor: Colors.orange,
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          backgroundColor: const Color(0xFFF4F4F4), // Chat screen background
          primaryColor: Colors.orange, // User message bubble
          secondaryColor: Colors.white, // Bot message bubble
          inputBackgroundColor: Colors.white,
          inputTextColor: Colors.black,
          sendButtonIcon: const Icon(Icons.send, color: Colors.orange),
          inputTextCursorColor: Colors.orange,
          receivedMessageBodyTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
