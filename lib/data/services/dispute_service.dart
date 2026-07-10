import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';

class DisputeService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Upload evidence for a dispute
  ///
  /// API: POST /api/Dispute/{id}/evidence
  Future<bool> uploadEvidence(String disputeId, List<int> fileBytes, String fileName) async {
    try {
      // For now, we'll use a simplified approach
      // In a real implementation, you'd use multipart/form-data
      final response = await _client.post(
        '/Dispute/$disputeId/evidence',
        body: {
          'fileName': fileName,
          'fileData': String.fromCharCodes(fileBytes),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Upload dispute evidence error: $e');
      rethrow;
    }
  }

  /// Send a message in a dispute
  ///
  /// API: POST /api/Dispute/{id}/messages
  Future<bool> sendMessage(String disputeId, String message) async {
    try {
      final response = await _client.post(
        '/Dispute/$disputeId/messages',
        body: {
          'message': message,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send dispute message error: $e');
      rethrow;
    }
  }

  /// Update dispute status
  ///
  /// API: PUT /api/Dispute/{id}/status
  Future<bool> updateStatus(String disputeId, String status) async {
    try {
      final response = await _client.put(
        '/Dispute/$disputeId/status',
        body: {
          'status': status,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update dispute status error: $e');
      rethrow;
    }
  }

  /// Get dispute details
  ///
  /// API: GET /api/Dispute/{id}
  Future<Map<String, dynamic>?> getDispute(String disputeId) async {
    try {
      final response = await _client.get('/Dispute/$disputeId');
      final body = response.body.tryParseJson();

      if (body == null) {
        return null;
      }

      // Handle nested data field
      return _extractData(body);
    } catch (e) {
      debugPrint('Get dispute error: $e');
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