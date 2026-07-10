import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight response wrapper that mirrors the `http.Response` interface
/// so existing services can keep using `response.body.tryParseJson()` unchanged.
class DioResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  const DioResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });
}

/// Centralised Dio-based HTTP client with token management and interceptors.
class DioClient {
  final Dio _dio;
  String? _token;
  void Function()? _onUnauthorized;

  DioClient(this._dio) {
    _dio.interceptors.addAll([
      _TokenInterceptor(this),
      _ErrorInterceptor(this),
    ]);
  }

  // ── Callback for 401 handling ──────────────────────────────

  /// Register a callback that fires on 401 Unauthorized.
  /// Typical use: clear AuthViewModel state and redirect to /login.
  void setOnUnauthorized(void Function() callback) {
    _onUnauthorized = callback;
  }

  void _handleUnauthorized() {
    clearToken();
    _onUnauthorized?.call();
  }

  // ── Token management ──────────────────────────────────────

  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null && token.isNotEmpty) {
      await prefs.setString('token', token);
    } else {
      await prefs.remove('token');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── HTTP methods (same signature as SecureHttpClient) ──────

  Future<DioResponse> get(String endpoint, {Duration? timeout}) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: _timeoutOptions(timeout),
      );
      return _toResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e, endpoint);
    }
  }

  Future<DioResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: _timeoutOptions(timeout),
      );
      return _toResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e, endpoint);
    }
  }

  Future<DioResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: _timeoutOptions(timeout),
      );
      return _toResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e, endpoint);
    }
  }

  Future<DioResponse> delete(String endpoint, {Duration? timeout}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: _timeoutOptions(timeout),
      );
      return _toResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e, endpoint);
    }
  }

  Future<DioResponse> postMultipart(
    String endpoint, {
    String? filePath,
    String? fileFieldName,
    Map<String, String>? fields,
    Duration? timeout,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (filePath != null && fileFieldName != null) {
        map[fileFieldName] = await MultipartFile.fromFile(filePath);
      }
      if (fields != null) map.addAll(fields);

      final formData = FormData.fromMap(map);

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: _timeoutOptions(timeout)?.copyWith(
          contentType: 'multipart/form-data',
        ),
      );
      return _toResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e, endpoint);
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  Options? _timeoutOptions(Duration? timeout) {
    if (timeout == null) return null;
    return Options(
      sendTimeout: timeout,
      receiveTimeout: timeout,
    );
  }

  DioResponse _toResponse(Response<dynamic> response) {
    final body = response.data is String
        ? response.data as String
        : jsonEncode(response.data);

    final headers = <String, String>{};
    response.headers.forEach((key, values) {
      headers[key] = values.join(', ');
    });

    return DioResponse(
      statusCode: response.statusCode ?? 0,
      body: body,
      headers: headers,
    );
  }

  Exception _mapDioError(DioException e, String endpoint) {
    debugPrint('[DioError] $endpoint: ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout. Please check your connection.');
      case DioExceptionType.connectionError:
        return Exception('Network error. Please check your connection.');
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  Exception _handleBadResponse(Response<dynamic>? response) {
    if (response == null) return Exception('No response from server');

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    final errorBody = data is Map<String, dynamic> ? data : null;

    switch (statusCode) {
      case 400:
        return Exception(_extractErrorMessage(errorBody) ?? 'Invalid request');
      case 401:
        _handleUnauthorized();
        return Exception('Session expired. Please login again.');
      case 403:
        return Exception('Access denied');
      case 404:
        return Exception('Resource not found');
      case 409:
        return Exception(_extractErrorMessage(errorBody) ?? 'Conflict');
      case 422:
        return Exception(_extractErrorMessage(errorBody) ?? 'Validation error');
      case 500:
        return Exception('Server error. Please try again later.');
      case 502:
      case 503:
        return Exception('Service temporarily unavailable');
      default:
        if (statusCode >= 500) {
          return Exception('Server error ($statusCode)');
        }
        return Exception('Request failed ($statusCode)');
    }
  }

  String? _extractErrorMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    if (body['message'] != null) return body['message'].toString();
    if (body['error'] != null) {
      if (body['error'] is String) return body['error'] as String;
      if (body['error'] is Map && body['error']['message'] != null) {
        return body['error']['message'].toString();
      }
    }
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      return (body['errors'] as List).first.toString();
    }
    return null;
  }
}

// ─── Interceptors ──────────────────────────────────────────

class _TokenInterceptor extends Interceptor {
  final DioClient _client;
  _TokenInterceptor(this._client);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _client.getToken();
    if (token != null && token.isNotEmpty) {
      final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      options.headers['Authorization'] = authToken;
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final DioClient _client;
  _ErrorInterceptor(this._client);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _client._handleUnauthorized();
    }
    handler.next(err);
  }
}

/// Extension for safe JSON parsing on any String.
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
