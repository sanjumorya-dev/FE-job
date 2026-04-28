import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/requirement_model.dart';
import '../models/applicant_model.dart';

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
      await _client.put(
        '/Requirement/update',
        body: request.toUpdateJson(id),
      );
    } catch (e) {
      debugPrint('Update requirement error: $e');
      rethrow;
    }
  }

  /// Delete a requirement
  Future<void> deleteRequirement(String id) async {
    try {
      await _client.delete('/Requirement/$id');
    } catch (e) {
      debugPrint('Delete requirement error: $e');
      rethrow;
    }
  }

  /// Change requirement status (Hold/Activate/Complete)
  ///
  /// [status]: 0 = Draft, 1 = Active, 2 = On Hold, 3 = Completed
  Future<void> changeRequirementStatus(String id, int status) async {
    try {
      await _client.put(
        '/Requirement/$id/status',
        body: {'status': status},
      );
    } catch (e) {
      debugPrint('Change requirement status error: $e');
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
        '/Requirement/owner',
        body: request.toJson(),
      );

      final body = response.body.tryParseJson();
      final list = _extractList(body, listKey: 'requirements');
      if (list != null) {
        return list.map((e) => Requirement.fromJson(e)).toList();
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
      await _client.post('/create', body: {'requirementId': requirementId});
    } catch (e) {
      debugPrint('Apply for requirement error: $e');
      rethrow;
    }
  }

  /// Get user's applications
  Future<List<Requirement>> getMyApplications() async {
    try {
      final response = await _client.get('/Requirement/byUserId?status=0');
      final dynamic body = jsonDecode(response.body);

      final list = _extractList(body, listKey: 'requirements');
      if (list != null) {
        return list.map((e) => Requirement.fromJson(e)).toList();
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

  /// Get applicants for a requirement
  Future<List<Applicant>> getApplicants(String requirementId) async {
    try {
      final response =
          await _client.get('/Requirement/$requirementId/applicants');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final applicantsData = _extractList(body, listKey: 'applicants');
      if (applicantsData == null) {
        return [];
      }

      return applicantsData
          .map((e) => _parseApplicant(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get applicants error: $e');
      rethrow;
    }
  }

  /// Get open jobs for workers with optional filters.
  Future<List<Requirement>> getLabourList({
    int pageNumber = 1,
    int pageSize = 10,
    String? workTypeId,
  }) async {
    try {
      final query = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        if (workTypeId != null && workTypeId.isNotEmpty)
          'workTypeId': workTypeId,
      };
      final response = await _client.get(
        '/User/labourList?${Uri(queryParameters: query).query}',
      );
      final body = response.body.tryParseJson();
      final list = _extractList(body, listKey: 'items') ??
          _extractList(body, listKey: 'requirements') ??
          _extractList(body, listKey: 'users');

      if (list == null) return [];
      return list.map((e) => Requirement.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Get labour list error: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>>? _extractList(dynamic body, {String? listKey}) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (body is! Map<String, dynamic>) return null;

    final candidates = <dynamic>[
      if (listKey != null) body[listKey],
      if (listKey != null) body[_capitalize(listKey)],
      body['data'],
      body['Data'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (candidate is Map<String, dynamic>) {
        final nested = _extractList(candidate, listKey: listKey);
        if (nested != null) return nested;
      }
    }

    return null;
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  /// Accept an applicant for a requirement
  Future<void> acceptApplicant(String requirementId, String applicantId) async {
    try {
      await _client
          .put('/Requirement/$requirementId/applicants/$applicantId/accept');
    } catch (e) {
      debugPrint('Accept applicant error: $e');
      rethrow;
    }
  }

  /// Reject an applicant for a requirement
  Future<void> rejectApplicant(String requirementId, String applicantId) async {
    try {
      await _client
          .put('/Requirement/$requirementId/applicants/$applicantId/reject');
    } catch (e) {
      debugPrint('Reject applicant error: $e');
      rethrow;
    }
  }

  /// Mark a job/requirement as completed
  Future<void> completeJob(String requirementId) async {
    try {
      await _client.put('/Requirement/$requirementId/complete');
    } catch (e) {
      debugPrint('Complete job error: $e');
      rethrow;
    }
  }

  /// Parse applicant from JSON
  Applicant _parseApplicant(Map<String, dynamic> json) {
    // Parse status
    final int statusValue = (json['status'] ?? json['Status'] ?? 0).toInt();
    ApplicationStatus status = ApplicationStatus.pending;
    switch (statusValue) {
      case 1:
        status = ApplicationStatus.accepted;
        break;
      case 2:
        status = ApplicationStatus.rejected;
        break;
      default:
        status = ApplicationStatus.pending;
    }

    // Parse workTypes if available
    final List<String> workTypes = [];
    final workTypesJson = json['workTypes'] ?? json['WorkTypes'];
    if (workTypesJson is List) {
      for (var wt in workTypesJson) {
        if (wt is String) {
          workTypes.add(wt);
        } else if (wt is Map && wt['name'] != null) {
          workTypes.add(wt['name'].toString());
        } else if (wt is Map && wt['Name'] != null) {
          workTypes.add(wt['Name'].toString());
        }
      }
    }

    return Applicant(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      userId: (json['userId'] ?? json['UserId'] ?? '').toString(),
      requirementId:
          (json['requirementId'] ?? json['RequirementId'] ?? '').toString(),
      workerName: (json['workerName'] ?? json['WorkerName'] ?? '').toString(),
      gender: (json['gender'] ?? json['Gender'] ?? '').toString(),
      experienceYears:
          (json['experienceYears'] ?? json['ExperienceYears'] ?? 0).toInt(),
      mobileNumber:
          (json['mobileNumber'] ?? json['MobileNumber'] ?? '').toString(),
      status: status,
      appliedDate: json['appliedDate'] != null
          ? DateTime.tryParse(json['appliedDate'].toString()) ?? DateTime.now()
          : json['AppliedDate'] != null
              ? DateTime.tryParse(json['AppliedDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      workTypes: workTypes.where((e) => e.trim().isNotEmpty).toList(),
    );
  }
}
