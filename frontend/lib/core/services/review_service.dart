import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/reviews';

  /// Submit a review for a truck
  static Future<http.Response> submitTruckReview({
    required String token,
    required String truckId,
    required String orderId,
    required int rating,
    String? comment,
  }) {
    return http.post(
      Uri.parse('$baseUrl/truck'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'truck_id': truckId,
        'order_id': orderId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );
  }

  /// Submit a review for a menu item
  static Future<http.Response> submitMenuItemReview({
    required String token,
    required String menuItemId,
    required String orderId,
    required int rating,
    String? comment,
  }) {
    return http.post(
      Uri.parse('$baseUrl/menu'),
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
  }

  /// Get reviews for a truck
  static Future<List<dynamic>> fetchTruckReviews(String truckId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/truck/$truckId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load truck reviews');
    }
  }

  /// Get reviews for a menu item
  static Future<List<dynamic>> fetchMenuItemReviews2(String menuItemId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/menu/$menuItemId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load your menu item reviews');
    }
  }

  /// Check if a truck was already rated for this order
  static Future<bool> checkIfTruckRated({
    required String token,
    required String orderId,
    required String truckId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/truck/check/$orderId/$truckId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isRated'] ?? false;
    } else {
      throw Exception('Failed to check truck rating status');
    }
  }

  /// Check if a menu item was already rated for this order
  static Future<bool> checkIfMenuItemRated({
    required String token,
    required String orderId,
    required String itemId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/check/$orderId/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isRated'] ?? false;
    } else {
      throw Exception('Failed to check menu item rating status');
    }
  }

  /// Get all menu item reviews submitted by the logged-in customer
  static Future<List<dynamic>> fetchMyMenuItemReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/menu/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load your menu item reviews');
    }
  }
}
