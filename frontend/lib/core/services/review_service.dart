import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/trucks';
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Submit a review for a truck
  static Future<http.Response> submitTruckReview({
    required String truckId,
    required int rating,
    String? comment,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/reviews/truck'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'truck_id': truckId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    return response;
  }

  /// Submit a review for a menu item
  static Future<http.Response> submitMenuItemReview({
    required String menuItemId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/reviews/menu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'menu_item_id': menuItemId,
        'order_id': orderId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    return response;
  }

  /// Get reviews for a truck
  static Future<List<dynamic>> fetchTruckReviews(String truckId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/reviews/truck/$truckId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load truck reviews');
    }
  }

  /// Get reviews for a menu item
  static Future<List<dynamic>> fetchMenuItemReviews(String menuItemId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/reviews/menu/$menuItemId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load menu item reviews');
    }
  }
}
