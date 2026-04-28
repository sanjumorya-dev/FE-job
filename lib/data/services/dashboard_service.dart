import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get dashboard statistics for owner
  ///
  /// Returns stats including:
  /// - activeRequirements: Number of active job postings
  /// - totalApplicants: Total number of applicants across all requirements
  /// - hiredWorkers: Number of workers hired
  /// - completedJobs: Number of completed jobs
  Future<OwnerDashboardStats> getOwnerDashboardStats() async {
    try {
      final response = await _client.get('/Dashboard/owner/stats');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      Map<String, dynamic> statsData;
      if (body['data'] is Map<String, dynamic>) {
        statsData = body['data'] as Map<String, dynamic>;
      } else if (body is Map<String, dynamic>) {
        statsData = body;
      } else {
        throw Exception('Invalid stats data format');
      }

      return OwnerDashboardStats.fromJson(statsData);
    } catch (e) {
      debugPrint('Get owner dashboard stats error: $e');
      rethrow;
    }
  }

  /// Get dashboard statistics for worker (if available in future)
  Future<WorkerDashboardStats> getWorkerDashboardStats() async {
    try {
      final response = await _client.get('/Dashboard/worker');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      Map<String, dynamic> statsData;
      if (body['data'] is Map<String, dynamic>) {
        statsData = body['data'] as Map<String, dynamic>;
      } else if (body is Map<String, dynamic>) {
        statsData = body;
      } else {
        throw Exception('Invalid stats data format');
      }

      return WorkerDashboardStats.fromJson(statsData);
    } catch (e) {
      debugPrint('Get worker dashboard stats error: $e');
      rethrow;
    }
  }
}
