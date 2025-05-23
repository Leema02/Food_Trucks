import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/payments';

  /// Handles Stripe payment flow.
  /// [amount] is in agorot (e.g., 2270 for ₪22.70)
  static Future<bool> pay(
    BuildContext context,
    int amount,
    Map<String, dynamic> metadata,
  ) async {
    try {
      // Step 1: Request clientSecret from backend
      final response = await http.post(
        Uri.parse('$_baseUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': 'ils',
          'metadata': metadata,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create payment intent");
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      if (clientSecret == null) {
        throw Exception("clientSecret not received");
      }

      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Food Trucks',
          style: ThemeMode.light,
        ),
      );

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      // Show Stripe-friendly error
      final errorMessage =
          e is StripeException ? e.error.message : e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Payment failed: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }
}
