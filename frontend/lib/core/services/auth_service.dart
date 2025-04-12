import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api/users";

  static Future<http.Response> signup(Map<String, dynamic> userData) async {
    final url = Uri.parse("$baseUrl/signup");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );
  }
}
