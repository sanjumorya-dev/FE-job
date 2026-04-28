import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/work_type_model.dart';

class WorkTypeService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get list of all work types
  ///
  /// API: GET /WorkType/list
  /// Auth: Not required
  Future<List<WorkType>> getWorkTypes() async {
    try {
      final response = await _client.get('/WorkType/list');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle wrapped response
      List<dynamic> workTypesData;
      if (body is Map && body.containsKey('data')) {
        workTypesData = body['data'] as List<dynamic>;
      } else if (body is List) {
        workTypesData = body as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }

      return workTypesData
          .map((json) => WorkType.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get work types error: $e');
      rethrow;
    }
  }
}
