import 'package:flutter/foundation.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/dio_client.dart';

class RatingService {
  final DioClient _client = sl<DioClient>();

  /// Check if a job can be rated (completed within last 7 days)
  ///
  /// Returns true if job was completed within 7 days, false if older or not completed
  Future<bool> canRateJob(String requirementId) async {
    try {
      // We need to fetch the requirement to check completion date
      final response = await _client.get('/Requirement/$requirementId');
      final body = response.body.tryParseJson();
      if (body == null) return false;

      final data = body['data'] ?? body;
      final completedAt = data['completedAt'] ?? data['CompletedAt'];
      final status = data['status'] ?? data['Status'];

      // Check if job is completed
      final isCompleted = (status is int ? status : int.tryParse(status.toString())) == 3;
      if (!isCompleted || completedAt == null) return false;

      final completedDate = DateTime.tryParse(completedAt.toString());
      if (completedDate == null) return false;

      final now = DateTime.now();
      final difference = now.difference(completedDate).inDays;

      return difference <= 7;
    } catch (e) {
      debugPrint('Can rate job error: $e');
      return false;
    }
  }

  /// Rate a worker (Owner rates Worker)
  ///
  /// [workerId] - The ID of the worker being rated
  /// [requirementId] - The requirement/job ID associated with the rating
  /// [rating] - Rating value (1-5)
  /// [feedback] - Optional text feedback
  /// [tags] - List of rating tags (e.g., ["Skilled worker", "Completed on time"])
  Future<void> rateWorker({
    required String workerId,
    required String requirementId,
    required int rating,
    String? feedback,
    List<String>? tags,
  }) async {
    try {
      await _client.post(
        '/Rating/worker',
        body: {
          'workerId': workerId,
          'requirementId': requirementId,
          'rating': rating,
          if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
        },
      );
    } catch (e) {
      debugPrint('Rate worker error: $e');
      rethrow;
    }
  }

  /// Rate an owner (Worker rates Owner)
  ///
  /// [ownerId] - The ID of the owner being rated
  /// [requirementId] - The requirement/job ID associated with the rating
  /// [rating] - Rating value (1-5)
  /// [feedback] - Optional text feedback
  /// [tags] - List of rating tags (e.g., ["Good communication", "Fair payment"])
  Future<void> rateOwner({
    required String ownerId,
    required String requirementId,
    required int rating,
    String? feedback,
    List<String>? tags,
  }) async {
    try {
      await _client.post(
        '/Rating/owner',
        body: {
          'ownerId': ownerId,
          'requirementId': requirementId,
          'rating': rating,
          if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
        },
      );
    } catch (e) {
      debugPrint('Rate owner error: $e');
      rethrow;
    }
  }
}
