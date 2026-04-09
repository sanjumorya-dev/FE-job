import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/user_model.dart';

class UserService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _client.get('/User/details');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid user data in response');
      }

      // Handle response wrapper with 'data' field
      dynamic userData = body;
      if (body.containsKey('data')) {
        userData = body['data'];
      }

      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception('Invalid user data format');
      }

      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Get profile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> payload) async {
    try {
      await _client.put('/User/update', body: payload);
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }
}
