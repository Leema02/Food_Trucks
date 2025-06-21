import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EstimateService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/orders';

  /// Fetch the stored estimate for a given order
  static Future<Map<String, dynamic>?> getEstimate(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('$baseUrl/$orderId/estimate');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['estimate'];
      } else {
        print('❌ Failed to fetch estimate: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Exception in getEstimate: $e');
      return null;
    }
  }

  /// Recalculate the estimate for a given order
  static Future<Map<String, dynamic>?> recalculateEstimate(
      String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('$baseUrl/$orderId/estimate');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['estimate'];
      } else {
        print('❌ Failed to recalculate estimate: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Exception in recalculateEstimate: $e');
      return null;
    }
  }

  /// Preview only partOne (waiting time) for a truck
  static Future<int?> previewPartOne(String truckId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('$baseUrl/preview-wait/$truckId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ preview-wait response: $data');

        // Safely extract waitingTimeInMinutes from the response
        if (data['waitingTimeInMinutes'] != null) {
          return (data['waitingTimeInMinutes'] as num).round();
        } else {
          print('⚠️ No waitingTimeInMinutes found in response.');
          return null;
        }
      } else {
        print('❌ Failed to preview partOne: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Exception in previewPartOne: $e');
      return null;
    }
  }
}
