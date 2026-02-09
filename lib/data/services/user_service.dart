import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      // Check if token already has 'Bearer ' prefix
      final authToken = token.contains('Bearer') ? token : 'Bearer $token';
      headers['Authorization'] = authToken;
    }

    return headers;
  }

  Future<User> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/details'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 401) {
      throw Exception(
          'Unauthorized: Token expired or invalid. Please login again.');
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // Handle response wrapper with 'data' field
      dynamic userData = body;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        userData = body['data'];
      }

      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception('Invalid user data in response: ${response.body}');
      }

      return User.fromJson(userData);
    } else {
      throw Exception(
          'Failed to fetch profile (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$baseUrl/User/update'),
      headers: await _getHeaders(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 401) {
      throw Exception(
          'Unauthorized: Token expired or invalid. Please login again.');
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to update profile (${response.statusCode}): ${response.body}');
    }
  }
}
