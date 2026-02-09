import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/requirement_model.dart';

class RequirementService {
  static const String baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> createRequirement(CreateRequirementRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Requirement/create'),
      headers: await _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create requirement: ${response.body}');
    }
  }

  Future<void> updateRequirement(String id, CreateRequirementRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Requirement/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update requirement: ${response.body}');
    }
  }

  Future<List<Requirement>> getRequirements({
    int status = 0,
    String? search,
    String? workTypeId,
    int page = 1,
    int limit = 10,
  }) async {
    final request = OwnerRequirementsRequest(
      status: status,
      search: search,
      workTypeId: workTypeId,
      page: page,
      limit: limit,
    );

    final response = await http.post(
      Uri.parse('$baseUrl/Requirement/Owner'),
      headers: await _getHeaders(),
      body: jsonEncode(request.toJson()),
    );

    print(
        'Get Requirements Response: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      print('Get Requirements Response: ${response}');
      final List<dynamic> data = jsonDecode(response.body);
      print('Get Requirements Response: ${response.body}');
      return data.map((e) => Requirement.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch requirements: ${response.body}');
    }
  }
}
