import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventBookingService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/bookings';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🟢 Submit a new event booking (customer)
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

  // 🟡 Fetch bookings for the logged-in customer
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

  // 🔵 Fetch bookings for truck owner
  static Future<List<dynamic>> getOwnerBookings() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/owner');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load owner bookings');
    }
  }

// 🔴 Update booking status (confirm or reject)
  static Future<http.Response> updateBookingStatus(
      String bookingId, String status,
      {double? totalAmount}) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$bookingId/status');

    final Map<String, dynamic> body = {'status': status};
    if (status == 'confirmed' && totalAmount != null) {
      body['total_amount'] = totalAmount;
    }

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return response;
  }

  // 🟤 Optional: Delete/cancel a booking
  static Future<http.Response> deleteBooking(String bookingId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$bookingId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
