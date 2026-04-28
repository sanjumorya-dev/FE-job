import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get list of notifications for the current user
  ///
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of notifications per page (default: 20)
  Future<List<Notification>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/Notification/list?page=$page&limit=$limit',
      );
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final notificationsData = _extractList(body, listKey: 'notifications');
      if (notificationsData == null) {
        return [];
      }

      return notificationsData
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get notifications error: $e');
      rethrow;
    }
  }

  /// Mark a notification as read
  ///
  /// [notificationId] - The ID of the notification to mark as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client.put('/Notification/$notificationId/read');
    } catch (e) {
      debugPrint('Mark notification read error: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _client.put('/Notification/mark-all-read');
    } catch (e) {
      debugPrint('Mark all notifications read error: $e');
      rethrow;
    }
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
