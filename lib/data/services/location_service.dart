import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';

class LocationService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Update location
  ///
  /// API: POST /api/Location/update
  Future<bool> updateLocation(double latitude, double longitude, String? address) async {
    try {
      final response = await _client.post(
        '/Location/update',
        body: {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update location error: $e');
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