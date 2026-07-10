import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/dio_client.dart';

/// Service to handle file uploads via multipart/form-data
class UploadService {
  final DioClient _client = sl<DioClient>();

  /// Upload a single image file and return the URL
  ///
  /// API: POST /Common/uploadImage
  Future<String> uploadImage(File file) async {
    try {
      final response = await _client.postMultipart(
        '/Common/uploadImage',
        filePath: file.path,
        fileFieldName: 'file',
      );

      final body = response.body.tryParseJson();
      if (body != null) {
        if (body['url'] != null) {
          return body['url'] as String;
        }
        if (body['imageUrl'] != null) {
          return body['imageUrl'] as String;
        }
        if (body['data'] is Map && (body['data'] as Map)['url'] != null) {
          return (body['data'] as Map)['url'].toString();
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

  /// Upload multiple images and return list of URLs
  Future<List<String>> uploadMultipleImages(List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadImage(file);
      urls.add(url);
    }
    return urls;
  }

  /// Upload profile image specifically
  ///
  /// Uses the same endpoint but returns the URL for profile use
  Future<String> uploadProfileImage(File file) async {
    return uploadImage(file);
  }
}
