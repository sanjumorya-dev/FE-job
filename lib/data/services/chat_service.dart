import 'package:flutter/foundation.dart';
import '../../core/http_client.dart';
import '../models/chat_model.dart';

class ChatService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Get list of conversations for the current user
  ///
  /// Returns a list of ChatConversation objects with participant info,
  /// last message, and unread count
  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _client.get('/Chat/conversations');
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final conversationsData = _extractList(body, listKey: 'conversations');
      if (conversationsData == null) {
        return [];
      }

      return conversationsData
          .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get conversations error: $e');
      rethrow;
    }
  }

  /// Get messages in a conversation
  ///
  /// [conversationId] - The conversation ID
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of messages per page (default: 50)
  Future<List<ChatMessage>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _client.get(
        '/Chat/conversations/$conversationId/messages?page=$page&limit=$limit',
      );
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      final messagesData = _extractList(body, listKey: 'messages');
      if (messagesData == null) {
        return [];
      }

      return messagesData
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get messages error: $e');
      rethrow;
    }
  }

  /// Send a message in a conversation
  ///
  /// [conversationId] - The conversation ID
  /// [text] - The message text to send
  ///
  /// Returns the sent message with server-generated ID and timestamp
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final response = await _client.post(
        '/Chat/conversations/$conversationId/messages',
        body: {'text': text},
      );
      final body = response.body.tryParseJson();

      if (body == null) {
        throw Exception('Invalid response format');
      }

      // Handle nested data field
      if (body['data'] != null && body['data'] is Map<String, dynamic>) {
        return ChatMessage.fromJson(body['data'] as Map<String, dynamic>);
      }

      return ChatMessage.fromJson(body as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Send message error: $e');
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
