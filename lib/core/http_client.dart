import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Secure HTTP Client with centralized token management and error handling
class SecureHttpClient {
  static const String _baseUrl = 'https://dihaadi-0lje.onrender.com/api/v1';

  String? _token;
  final bool _isRefreshing = false;

  // Singleton pattern
  static final SecureHttpClient _instance = SecureHttpClient._internal();
  factory SecureHttpClient() => _instance;
  SecureHttpClient._internal();

  /// Get stored token from memory or SharedPreferences
  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  /// Set token in memory and persist to SharedPreferences
  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }

  /// Clear token (logout)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// Get headers with authorization
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final headers = <String, String>{
      if (!isMultipart) 'Content-Type': 'application/json',
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      // Ensure token has Bearer prefix
      final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      headers['Authorization'] = authToken;
    }

    return headers;
  }

  /// Generic GET request
  Future<http.Response> get(String endpoint, {Duration? timeout}) async {
    return await _executeRequest(
      () async => http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await getHeaders(),
      ),
      endpoint: endpoint,
      timeout: timeout,
    );
  }

  /// Generic POST request with JSON body
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    return await _executeRequest(
      () async => http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ),
      endpoint: endpoint,
      timeout: timeout,
    );
  }

  /// Generic PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    return await _executeRequest(
      () async => http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ),
      endpoint: endpoint,
      timeout: timeout,
    );
  }

  /// Generic DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Duration? timeout,
  }) async {
    return await _executeRequest(
      () async => http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await getHeaders(),
      ),
      endpoint: endpoint,
      timeout: timeout,
    );
  }

  /// Multipart POST request (for file uploads)
  Future<http.Response> postMultipart(
    String endpoint, {
    List<http.MultipartFile>? files,
    Map<String, String>? fields,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await getHeaders(isMultipart: true));

      if (files != null) {
        request.files.addAll(files);
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _validateResponse(response, endpoint);
      return response;
    } catch (e) {
      debugPrint('Multipart request failed: $e');
      rethrow;
    }
  }

  /// Execute request with timeout and error handling
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() requestFn, {
    required String endpoint,
    Duration? timeout,
  }) async {
    try {
      final response =
          await requestFn().timeout(timeout ?? const Duration(seconds: 30));

      _validateResponse(response, endpoint);
      return response;
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Exception for $endpoint: $e');
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('Format Exception for $endpoint: $e');
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('Request failed for $endpoint: $e');
      rethrow;
    }
  }

  /// Validate response and handle errors
  void _validateResponse(http.Response response, String endpoint) {
    debugPrint('[HTTP ${response.statusCode}] $endpoint');

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return;
      case 400:
        final error = _parseErrorResponse(response.body);
        throw Exception(error);
      case 401:
        // Clear invalid token and throw
        clearToken();
        throw Exception('Session expired. Please login again.');
      case 403:
        throw Exception('Access denied');
      case 404:
        throw Exception('Resource not found');
      case 409:
        final error = _parseErrorResponse(response.body);
        throw Exception(error);
      case 422:
        final error = _parseErrorResponse(response.body);
        throw Exception(error);
      case 500:
        throw Exception('Server error. Please try again later.');
      case 502:
      case 503:
        throw Exception('Service temporarily unavailable');
      default:
        if (response.statusCode >= 500) {
          throw Exception('Server error (${response.statusCode})');
        }
        throw Exception('Request failed (${response.statusCode})');
    }
  }

  /// Parse error response body
  String _parseErrorResponse(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        // Try common error response formats
        if (data['message'] != null) return data['message'];
        if (data['error'] != null) {
          if (data['error'] is String) return data['error'];
          if (data['error'] is Map && data['error']['message'] != null) {
            return data['error']['message'];
          }
        }
        if (data['errors'] is List) {
          return (data['errors'] as List).first.toString();
        }
      }
    } catch (_) {
      // Ignore parse errors
    }
    return 'Request failed';
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

/// Extension for safe JSON parsing
extension SafeJsonParse on String {
  Map<String, dynamic>? tryParseJson() {
    try {
      final data = jsonDecode(this);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}
