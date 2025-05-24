import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:myapp/screens/auth/login/login.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:myapp/screens/customer/ChatBotPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  Stripe.publishableKey =
      "pk_test_51RRdZMIee5pLQ5EwAOSGDbauHv7IMZqJvSg1hQwWc9BbfoPHUXFqN7wDME95xPBat7lBW2vY9yYhYnN9pu6DmU7n00gbcWkxbm"; // From your Stripe dashboard
  Stripe.instance.applySettings();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/langs', // Translation files location
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Truck',
      theme: ThemeData(primarySwatch: Colors.orange),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/chatbot': (context) => const ChatBotPage(),
      },
    );
  }
}
