import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dihaadi_app/constants/api_config.dart';

class CommonService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Content-Type': 'multipart/form-data',
    };

    if (token != null && token.isNotEmpty) {
      final authToken = token.contains('Bearer') ? token : 'Bearer $token';
      headers['Authorization'] = authToken;
    }

    return headers;
  }

  Future<String> uploadImage(File file) async {
    try {
      final uri = Uri.parse(ApiConfig.uploadImage);
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll(await _getHeaders());
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['imageUrl'] != null) {
          return body['imageUrl'];
        } else if (body is Map<String, dynamic> && body['data'] != null) {
             return body['data'];
        } else if (body is String) {
            return body;
        }
        throw Exception('Invalid response format: ${response.body}');
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
