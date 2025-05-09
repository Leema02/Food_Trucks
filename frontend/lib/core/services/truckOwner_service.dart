import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TruckOwnerService {
  // static const String baseUrl = "http://192.168.10.3:5000/api/trucks";
  // static const String baseUrl = "http:/10.0.2.2:5000/api/trucks";

  static final String baseUrl = Platform.isAndroid
      ? "http://192.168.10.1:5000/api/trucks" // real device on WiFi
      : "http://10.0.2.2:5000/api/trucks"; // Android emulator

  static Future<http.Response> addTruck(
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

  static Future<http.Response> getMyTrucks(String token) async {
    final url = Uri.parse("$baseUrl/my-trucks");

    return await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  static Future<http.Response> updateTruck(
      String id, Map<String, dynamic> truckData, String token) async {
    final url = Uri.parse("$baseUrl/$id");

    return await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(truckData),
    );
  }

  static Future<http.Response> deleteTruck(String id, String token) async {
    final url = Uri.parse("$baseUrl/$id");

    return await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  // 🌐 Public: Get all trucks (for customer view)
  static Future<List<dynamic>> getPublicTrucks() async {
    final url = Uri.parse("$baseUrl/public");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load trucks: ${response.statusCode}");
    }
  }
}
