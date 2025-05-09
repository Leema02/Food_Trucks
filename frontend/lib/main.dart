import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Truck',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const LoginPage(), // Initial screen
      routes: {
        // 'details': (context) => MealDetailPage(
        //       image: '',
        //       name: '',
        //       price: '',
        //     ),
        // 'cart': (context) => Cart(), // 👈 navigate to this later
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
