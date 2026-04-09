import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/requirement_model.dart';

class RequirementService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Create new requirement
  Future<void> createRequirement(CreateRequirementRequest request) async {
    try {
      await _client.post('/Requirement/create', body: request.toJson());
    } catch (e) {
      debugPrint('Create requirement error: $e');
      rethrow;
    }
  }

  /// Update existing requirement
  Future<void> updateRequirement(
      String id, CreateRequirementRequest request) async {
    try {
      await _client.put('/Requirement/$id', body: request.toJson());
    } catch (e) {
      debugPrint('Update requirement error: $e');
      rethrow;
    }
  }

  /// Get requirements with filters
  Future<List<Requirement>> getRequirements({
    int status = 0,
    String? search,
    String? workTypeId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final request = OwnerRequirementsRequest(
        status: status,
        search: search,
        workTypeId: workTypeId,
        page: page,
        limit: limit,
      );

      final response = await _client.post(
        '/Requirement/Owner',
        body: request.toJson(),
      );

      final body = response.body.tryParseJson();
      if (body != null && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => Requirement.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get requirements error: $e');
      rethrow;
    }
  }

  /// Apply for a requirement
  Future<void> applyForRequirement(String requirementId) async {
    try {
      await _client.post('/Requirement/apply/$requirementId');
    } catch (e) {
      debugPrint('Apply for requirement error: $e');
      rethrow;
    }
  }

  /// Get user's applications
  Future<List<Requirement>> getMyApplications() async {
    try {
      final response = await _client.get('/Requirement/my-applications');
      final dynamic body = jsonDecode(response.body);

      if (body is List) {
        return body
            .map((e) => Requirement.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (body is Map<String, dynamic> && body['data'] is List) {
        return (body['data'] as List)
            .map((e) => Requirement.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Get applications error: $e');
      rethrow;
    }
  }

  /// Get requirement by ID
  Future<Requirement> getRequirementById(String id) async {
    try {
      final response = await _client.get('/Requirement/$id');
      final body = response.body.tryParseJson();

      if (body != null) {
        // Handle nested data field
        if (body['data'] != null) {
          return Requirement.fromJson(body['data']);
        }
        return Requirement.fromJson(body);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('Get requirement by ID error: $e');
      rethrow;
    }
  }
}
