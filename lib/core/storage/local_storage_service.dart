import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// LocalStorageService handles persistent storage of tokens and user data
/// using SharedPreferences.
class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  late SharedPreferences _prefs;

  /// Initialize the storage service. Must be called before using any methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get authentication token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Save user data as JSON
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// Save user role
  Future<void> saveRole(String role) async {
    await _prefs.setString(_roleKey, role);
  }

  /// Get user role
  String? getRole() {
    return _prefs.getString(_roleKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    await _prefs.remove(_roleKey);
  }

  /// Clear only token (for token refresh)
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}

/// Singleton instance for easy access
final LocalStorageService localStorageService = LocalStorageService();