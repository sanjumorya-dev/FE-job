import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';

class RatingService {
  final SecureHttpClient _client = SecureHttpClient();

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
