import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TruckCapacityService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/trucks/capacity';

  /// Get capacity for a specific truck
  static Future<int?> getCapacity(String truckId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/$truckId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['maxConcurrent'] as int?;
      } else {
        print('❌ Failed to get capacity: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching capacity: $e');
      return null;
    }
  }

  /// Set or update capacity for a truck
  static Future<bool> setCapacity(String truckId, int maxConcurrent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'truckId': truckId,
          'maxConcurrent': maxConcurrent,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Failed to set capacity: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error setting capacity: $e');
      return false;
    }
  }
}
