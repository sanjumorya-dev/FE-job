import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';

class ConfigService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Sync configuration from server
  ///
  /// API: GET /api/Config/sync
  Future<Map<String, dynamic>> syncConfig() async {
    try {
      final response = await _client.get('/Config/sync');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final configData = _extractData(body);
      if (configData == null) {
        return {};
      }

      return configData;
    } catch (e) {
      debugPrint('Config sync error: $e');
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