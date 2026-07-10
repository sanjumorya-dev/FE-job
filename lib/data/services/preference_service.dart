import 'package:flutter/foundation.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/dio_client.dart';

class PreferenceService {
  final DioClient _client = sl<DioClient>();

  /// Update user preferences
  ///
  /// API: PUT /api/Preference/update
  Future<bool> updatePreference(Map<String, dynamic> preferences) async {
    try {
      final response = await _client.put(
        '/Preference/update',
        body: preferences,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update preference error: $e');
      rethrow;
    }
  }

  // Helper method to extract data from response
  Map<String, dynamic>? _extractData(dynamic body) {
    if (body is Map<String, dynamic>) {
      // Check if data is directly in the response
      if (body.isNotEmpty &&
          (body.keys.any((key) => !['status', 'message', 'success'].contains(key.toLowerCase())))) {
        return body;
      }
      // Check if data is nested in a 'data' field
      if (body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      // Check if data is nested in a 'Data' field
      if (body['Data'] is Map<String, dynamic>) {
        return body['Data'] as Map<String, dynamic>;
      }
    }
    return null;
  }
}