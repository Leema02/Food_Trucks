import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // static const String baseUrl = "http://10.0.2.2:5000/api/orders";
  static final String baseUrl = Platform.isAndroid
      ? "http://192.168.10.1:5000/api/orders" // real device on WiFi
      : "http://10.0.2.2:5000/api/orders"; // Android emulator

  static Future<http.Response> placeOrder(
      Map<String, dynamic> orderData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(orderData),
    );
  }

  static Future<http.Response> getMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return await http.get(
      Uri.parse("$baseUrl/my"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  static Future<http.Response> getOrdersByTruck(String truckId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return await http.get(
      Uri.parse("$baseUrl/truck/$truckId"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  static Future<http.Response> updateOrderStatus(
      String orderId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return await http.put(
      Uri.parse("$baseUrl/$orderId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"status": status}),
    );
  }
}
