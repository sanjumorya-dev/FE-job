import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/user_model.dart';

class AuthService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Login with mobile number and password
  Future<User> login(String mobileNumber, String password, {String? countryCode}) async {
    try {
      final response = await _client.post(
        '/Auth/login',
        body: {
          'MobileNumber': mobileNumber,
          'CountryCode': countryCode ?? '+91',
          'Password': password,
        },
      );

      final data = response.body.tryParseJson();
      if (data == null) {
        throw Exception('Invalid login response format');
      }

      // Extract token from response (handle both top-level and nested)
      String? token = data['token'];
      if (token == null && data['data'] is Map<String, dynamic>) {
        token = (data['data'] as Map<String, dynamic>)['token'];
      }

      if (token == null || token.isEmpty) {
        throw Exception('No token found in login response');
      }

      // Save token securely
      await _client.setToken(token);

      // Extract user data from response
      Map<String, dynamic>? userData;
      if (data['user'] is Map<String, dynamic>) {
        userData = data['user'];
      } else if (data.containsKey('id') || data.containsKey('name')) {
        userData = data;
      } else if (data['data'] is Map<String, dynamic>) {
        final dataObj = data['data'] as Map<String, dynamic>;
        userData = dataObj['user'] as Map<String, dynamic>? ?? dataObj;
      }

      if (userData == null) {
        throw Exception('User data missing in login response');
      }

      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(CreateUserRequest request) async {
    try {
      final response = await _client.post(
        '/User/create',
        body: request.toJson(),
      );

      final data = response.body.tryParseJson();
      return data ?? {};
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Send OTP to mobile number
  Future<bool> sendOtp(String mobileNumber, {String? countryCode}) async {
    try {
      final response = await _client.post(
        '/Auth/otpRequest',
        body: {
          'MobileNumber': mobileNumber,
          'CountryCode': countryCode ?? '+91',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      return false;
    }
  }

  /// Verify OTP and return token
  Future<String?> verifyOtp(String mobileNumber, String otp, {String? countryCode}) async {
    try {
      final response = await _client.post(
        '/Auth/otpVerify',
        body: {
          'MobileNumber': mobileNumber,
          'CountryCode': countryCode ?? '+91',
          'OtpCode': otp,
          'OtpType': 0,
        },
      );

      if (response.statusCode == 200) {
        final data = response.body.tryParseJson();
        if (data != null) {
          String? token = data['token'];
          if (token == null && data['data'] is Map<String, dynamic>) {
            token = (data['data'] as Map<String, dynamic>)['token'];
          }
          if (token != null && token.isNotEmpty) {
            await _client.setToken(token);
            return token;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return null;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _client.post(
        '/Auth/resetPassword',
        body: {
          'token': token,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  /// Logout - clear stored token
  Future<void> logout() async {
    await _client.clearToken();
  }
}
