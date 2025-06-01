import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TruckOwnerService {
  // static const String baseUrl = "http://192.168.10.3:5000/api/trucks";
  static const String baseUrl = "http://10.0.2.2:5000/api/trucks";

  // static final String baseUrl = Platform.isAndroid
  //     ? "http://10.0.2.2:5000/api/trucks" // Android emulator
  //     : "http://192.168.10.4:5000/api/trucks"; // real device on WiFi

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

// 🌐 Public: Get all trucks (optionally filter by city)
  static Future<List<dynamic>> getPublicTrucks({String? city}) async {
    final uri = Uri.parse("$baseUrl/public").replace(queryParameters: {
      if (city != null && city.isNotEmpty) 'city': city,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load trucks: ${response.statusCode}");
    }
  }

  static Future<List<String>> getAllCuisines(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cuisines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load cuisines');
    }
  }

  /// ✅ Get trucks filtered by cuisine type
  static Future<List<dynamic>> getTrucksByCuisine(String cuisine) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl?cuisine=$cuisine&limit=50'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['trucks']; // returns List<dynamic>
    } else {
      throw Exception('Failed to load trucks by cuisine');
    }
  }

  /// ✅ Get trucks sorted by average rating
  static Future<List<dynamic>> getHighestRatedTrucks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl?sort=rating&limit=20'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['trucks'];
    } else {
      throw Exception('Failed to load highest rated trucks');
    }
  }

  /// ✅ Get trucks that are currently open
  static Future<List<dynamic>> getOpenNowTrucks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl?openNow=true&limit=20'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['trucks'];
    } else {
      throw Exception('Failed to load open now trucks');
    }
  }
}
