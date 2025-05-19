import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvailabilityService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/trucks';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<DateTime>> getUnavailableDates(String truckId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$truckId');

    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = data['unavailable_dates'] as List;
      return dates.map((d) => DateTime.parse(d)).toList();
    } else {
      throw Exception('Failed to fetch unavailable dates');
    }
  }

  static Future<void> addUnavailableDate(String truckId, DateTime date) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$truckId/unavailable');

    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'date': date.toIso8601String()}));

    if (response.statusCode != 200) {
      throw Exception('Failed to add unavailable date');
    }
  }

  static Future<void> removeUnavailableDate(
      String truckId, DateTime date) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$truckId/unavailable');

    final response = await http.delete(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'date': date.toIso8601String()}));

    if (response.statusCode != 200) {
      throw Exception('Failed to remove unavailable date');
    }
  }
}
