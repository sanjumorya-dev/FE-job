import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/work_type_model.dart';

class WorkTypeService {
  static const String baseUrl =
      'https://dihaadi-0lje.onrender.com/api/v1'; // Update with your API URL

  Future<List<WorkType>> getWorkTypes() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/WorkType/list'),
            headers: _getHeaders(),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Handle wrapped response
        List<dynamic> workTypesData;
        if (body is Map && body.containsKey('data')) {
          workTypesData = body['data'] as List<dynamic>;
        } else if (body is List) {
          workTypesData = body;
        } else {
          throw Exception('Unexpected response format');
        }

        return workTypesData
            .map((json) => WorkType.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
            'Failed to load work types: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching work types: $e');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
