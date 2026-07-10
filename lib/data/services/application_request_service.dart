import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/application_request_model.dart';

class ApplicationRequestService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Create a new application for a requirement
  ///
  /// API: POST /api/v1/ApplicationRequest/CreateApplication
  Future<ApplicationRequest> createApplication(CreateApplicationRequest request) async {
    try {
      final response = await _client.post(
        '/ApplicationRequest/CreateApplication',
        body: request.toJson(),
      );

      final body = response.body.tryParseJson();
      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final applicationData = _extractData(body);
      if (applicationData == null) {
        throw Exception('Application data not found in response');
      }

      return ApplicationRequest.fromJson(applicationData);
    } catch (e) {
      debugPrint('Create application error: $e');
      rethrow;
    }
  }

  /// Get applications by requirement ID
  ///
  /// API: GET /api/v1/ApplicationRequest/ApplicationsByRequirementId
  Future<List<ApplicationRequest>> getApplicationsByRequirementId(String requirementId) async {
    try {
      final response = await _client.get(
        '/ApplicationRequest/ApplicationsByRequirementId?requirementId=$requirementId',
      );

      final body = response.body.tryParseJson();
      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final applicationsData = _extractList(body, listKey: 'applications');
      if (applicationsData == null) {
        return [];
      }

      return applicationsData
          .map((e) => ApplicationRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get applications by requirement ID error: $e');
      rethrow;
    }
  }

  /// Get applications for the current worker
  ///
  /// API: GET /api/v1/ApplicationRequest/worker
  Future<List<ApplicationRequest>> getWorkerApplications() async {
    try {
      final response = await _client.get('/ApplicationRequest/worker');

      final body = response.body.tryParseJson();
      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final applicationsData = _extractList(body, listKey: 'applications');
      if (applicationsData == null) {
        return [];
      }

      return applicationsData
          .map((e) => ApplicationRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get worker applications error: $e');
      rethrow;
    }
  }

  /// Update application status
  ///
  /// API: PUT /api/v1/ApplicationRequest/status
  Future<void> updateApplicationStatus(UpdateApplicationStatusRequest request) async {
    try {
      await _client.put(
        '/ApplicationRequest/status',
        body: request.toJson(),
      );
    } catch (e) {
      debugPrint('Update application status error: $e');
      rethrow;
    }
  }

  // Helper methods
  Map<String, dynamic>? _extractData(dynamic body) {
    if (body is Map<String, dynamic>) {
      // Check if data is directly in the response
      if (body.containsKey('id') || body.containsKey('applicationId')) {
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

  List<Map<String, dynamic>>? _extractList(dynamic body, {required String listKey}) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (body is! Map<String, dynamic>) return null;

    final candidates = [
      body[listKey],
      body[listKey[0].toUpperCase() + listKey.substring(1)],
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
}

/// Request model for creating an application
class CreateApplicationRequest {
  final String requirementId;
  final String? coverLetter;
  final List<String>? skills;

  CreateApplicationRequest({
    required this.requirementId,
    this.coverLetter,
    this.skills,
  });

  Map<String, dynamic> toJson() {
    return {
      'requirementId': requirementId,
      if (coverLetter != null && coverLetter!.isNotEmpty) 'coverLetter': coverLetter,
      if (skills != null && skills.isNotEmpty) 'skills': skills,
    };
  }
}

/// Request model for updating application status
class UpdateApplicationStatusRequest {
  final String applicationId;
  final int status; // 0 = Pending, 1 = Accepted, 2 = Rejected, 3 = Completed

  UpdateApplicationStatusRequest({
    required this.applicationId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'status': status,
    };
  }
}

/// Model for application request
class ApplicationRequest {
  final String id;
  final String requirementId;
  final String workerId;
  final String? workerName;
  final String? workerMobileNumber;
  final DateTime? appliedDate;
  final int status; // 0 = Pending, 1 = Accepted, 2 = Rejected, 3 = Completed
  final String? statusText;
  final String? coverLetter;
  final List<String>? skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApplicationRequest({
    required this.id,
    required this.requirementId,
    required this.workerId,
    this.workerName,
    this.workerMobileNumber,
    this.appliedDate,
    required this.status,
    this.statusText,
    this.coverLetter,
    this.skills,
    this.createdAt,
    this.updatedAt,
  });

  factory ApplicationRequest.fromJson(Map<String, dynamic> json) {
    return ApplicationRequest(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      requirementId: (json['requirementId'] ?? json['RequirementId'] ?? '').toString(),
      workerId: (json['workerId'] ?? json['WorkerId'] ?? '').toString(),
      workerName: (json['workerName'] ?? json['WorkerName'] ?? '').toString(),
      workerMobileNumber: (json['workerMobileNumber'] ?? json['WorkerMobileNumber'] ?? '').toString(),
      appliedDate: json['appliedDate'] != null
          ? DateTime.tryParse(json['appliedDate'].toString())
          : json['AppliedDate'] != null
              ? DateTime.tryParse(json['AppliedDate'].toString())
              : null,
      status: (json['status'] ?? json['Status'] ?? 0).toInt(),
      statusText: (json['statusText'] ?? json['StatusText'] ?? '').toString(),
      coverLetter: (json['coverLetter'] ?? json['CoverLetter'] ?? '').toString(),
      skills: (json['skills'] ?? json['Skills'] ?? [])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['CreatedAt'] != null
              ? DateTime.tryParse(json['CreatedAt'].toString())
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : json['UpdatedAt'] != null
              ? DateTime.tryParse(json['UpdatedAt'].toString())
              : null,
    );
  }
}