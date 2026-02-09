import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User> login(String mobileNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid login response format');
      }

      // Try to extract token from response (handle both top-level and nested)
      String? token = data['token'];
      if (token == null && data['data'] is Map<String, dynamic>) {
        final dataObj = data['data'] as Map<String, dynamic>;
        token = dataObj['token'];
      }

      // Save token if found
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      } else {
        throw Exception('No token found in login response: ${response.body}');
      }

      // Try multiple possible locations for user data
      Map<String, dynamic>? userData;

      // Check if user data is directly in response
      if (data['user'] is Map<String, dynamic>) {
        userData = data['user'] as Map<String, dynamic>;
      }
      // Check if the entire response is user data (some APIs return user directly)
      else if (data.containsKey('id') ||
          data.containsKey('Id') ||
          data.containsKey('name') ||
          data.containsKey('Name')) {
        userData = data;
      }
      // Check for nested data object
      else if (data['data'] is Map<String, dynamic>) {
        final dataObj = data['data'] as Map<String, dynamic>;
        if (dataObj['user'] is Map<String, dynamic>) {
          userData = dataObj['user'] as Map<String, dynamic>;
        } else {
          userData = dataObj;
        }
      }

      if (userData == null) {
        throw Exception(
            'User data missing in login response: ${response.body}');
      }

      return User.fromJson(userData);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> register(CreateUserRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/User/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register: \\${response.body}');
    }
  }

  /// Sample API: send OTP to mobile
  Future<bool> sendOtp(String mobileNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/otpRequest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobileNumber': mobileNumber}),
    );

    if (response.statusCode == 200) return true;
    return false;
  }

  /// Sample API: verify OTP. Returns token string on success (nullable).
  Future<String?> verifyOtp(String mobileNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/otpVerify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'mobileNumber': mobileNumber, 'otpCode': otp, 'otpType': 0}),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // Try common locations for token
        if (data is Map<String, dynamic>) {
          if (data['token'] is String) return data['token'] as String;
          if (data['data'] is Map && data['data']['token'] is String) {
            return data['data']['token'] as String;
          }
        }
      } catch (_) {
        // ignore parse errors
      }
    }
    return null;
  }

  /// Sample API: reset password
  Future<bool> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/resetPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) return true;
    return false;
  }

  // Additional auth-related APIs can be added here (logout, refresh token, etc.)
}
