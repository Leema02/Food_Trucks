import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home.dart'; // ✅ imports your real homepage

void main() {
  runApp(const MyApp()); // ✅ launches the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ hides the debug banner
      home: HomePage(), // ✅ loads your `HomePage` from home.dart
    );
  }
}
