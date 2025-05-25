import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuService {
  //static const String baseUrl = "http://192.168.10.3:5000/api/menu";
  static const String baseUrl = "http://10.0.2.2:5000/api/menu";

  static Future<http.Response> addMenuItem(
      String token, Map<String, dynamic> data) {
    return http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getMenuItems(String truckId) async {
    final url = Uri.parse("$baseUrl/$truckId");
    return await http.get(url);
  }

  static Future<http.Response> updateMenuItem(
      String itemId, Map<String, dynamic> data, String token) {
    final url = Uri.parse("$baseUrl/$itemId");

    return http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> deleteMenuItem(
      String itemId, String token) async {
    final url = Uri.parse("$baseUrl/$itemId");

    return await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getAllMenusWithTrucks() async {
    final url = Uri.parse("$baseUrl/all");
    return await http.get(url);
  }
}
