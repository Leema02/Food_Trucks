import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventBookingService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/bookings';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<http.Response> submitBooking(Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  static Future<List<dynamic>> getMyBookings() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/my');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}
