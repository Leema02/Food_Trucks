import 'dart:convert';
import 'package:http/http.dart' as http;

class TruckOwnerService {
  static const String baseUrl = "http://10.0.2.2:5000/api/trucks";

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
}
