import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/http_client.dart';

class CommonService {
  final SecureHttpClient _client = SecureHttpClient();

  /// Upload image to server
  Future<String> uploadImage(File file) async {
    try {
      final response = await _client.postMultipart(
        '/common/upload-image',
        files: [
          await http.MultipartFile.fromPath('file', file.path),
        ],
      );

      final body = response.body.tryParseJson();
      if (body != null) {
        if (body['imageUrl'] != null) {
          return body['imageUrl'] as String;
        }
        if (body['data'] != null) {
          return body['data'].toString();
        }
      }

      // Handle string response
      if (response.body.isNotEmpty && !response.body.startsWith('{')) {
        return response.body;
      }

      throw Exception('Invalid response format from image upload');
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
