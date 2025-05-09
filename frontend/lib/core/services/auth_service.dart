import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  //static const String baseUrl = "http://10.0.2.2:5000/api/users";
  // static const String baseUrl = "http://192.168.10.7:5000/api/users";
  static String baseUrl = Platform.isAndroid
      ? "http://10.0.2.2:5000/api/users" // for emulator
      : "http://192.168.10.1:5000/api/users"; // for real phone

  static Future<http.Response> signup(Map<String, dynamic> userData) async {
    final url = Uri.parse("$baseUrl/signup");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );
  }

  static Future<http.Response> login(Map<String, dynamic> credentials) async {
    final url = Uri.parse("$baseUrl/login");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(credentials),
    );
  }

  static Future<http.Response> forgotPassword(
      Map<String, dynamic> emailData) async {
    final url = Uri.parse("$baseUrl/forgot-password");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(emailData),
    );
  }

  static Future<http.Response> verifyResetCode(
      Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/verify-reset-code");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> resetPassword(String email, String password) {
    final url = Uri.parse("$baseUrl/reset-password");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email_address": email, "password": password}),
    );
  }
}
