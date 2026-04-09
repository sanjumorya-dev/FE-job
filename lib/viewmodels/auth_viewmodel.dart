import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/user_service.dart';
import '../core/validators.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Normalize mobile number and country code
  ({String mobile, String countryCode}) _normalizeMobileWithCode(
    String mobile,
    String countryCode,
  ) {
    final trimmedMobile = mobile.trim();
    final normalizedCode = countryCode.trim().isEmpty
        ? '+91'
        : (countryCode.trim().startsWith('+')
            ? countryCode.trim()
            : '+${countryCode.trim()}');

    if (!trimmedMobile.startsWith('+')) {
      return (mobile: trimmedMobile, countryCode: normalizedCode);
    }

    final match = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(trimmedMobile);
    if (match != null) {
      return (
        mobile: match.group(2) ?? trimmedMobile,
        countryCode: match.group(1) ?? normalizedCode,
      );
    }

    return (mobile: trimmedMobile, countryCode: normalizedCode);
  }

  /// Check if user is already logged in (persistence)
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _userService.getProfile();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Auth check error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with mobile and password
  Future<bool> login(String mobileNumber, String password,
      {String countryCode = '+91'}) async {
    // Validate inputs
    final mobileError = Validators.validateMobile(mobileNumber);
    if (mobileError != null) {
      _error = mobileError;
      notifyListeners();
      return false;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      _error = passwordError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = _normalizeMobileWithCode(mobileNumber, countryCode);
      _currentUser = await _authService.login(
        normalized.mobile,
        password,
        countryCode: normalized.countryCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user - returns true on success, triggers OTP flow
  Future<bool> register(CreateUserRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch current user profile
  Future<bool> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _userService.getProfile();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.updateProfile(payload);
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout - clear session
  Future<void> logout() async {
    _currentUser = null;
    await _authService.logout();
    notifyListeners();
  }

  /// Send OTP for verification
  Future<bool> sendOtp(String mobileNumber,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final normalized = _normalizeMobileWithCode(mobileNumber, countryCode);
      final ok = await _authService.sendOtp(
        normalized.mobile,
        countryCode: normalized.countryCode,
      );
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP and get authentication token
  Future<String?> verifyOtp(String mobileNumber, String otp,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final normalized = _normalizeMobileWithCode(mobileNumber, countryCode);
      final token = await _authService.verifyOtp(
        normalized.mobile,
        otp,
        countryCode: normalized.countryCode,
      );

      // Fetch user profile after successful OTP verification
      if (token != null) {
        try {
          _currentUser = await _userService.getProfile();
        } catch (_) {
          // User profile fetch failed but token is valid
          debugPrint('Failed to fetch profile after OTP verification');
        }
      }

      _isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _authService.resetPassword(token, newPassword);
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Format error message for display
  String _formatError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('Network error') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('HttpException')) {
      return 'Network error. Please check your connection.';
    }
    if (errorStr.contains('Session expired')) {
      return 'Session expired. Please login again.';
    }
    if (errorStr.contains('400')) {
      return 'Invalid request. Please check your inputs.';
    }
    if (errorStr.contains('401')) {
      return 'Authentication failed. Please login again.';
    }
    if (errorStr.contains('500') || errorStr.contains('503')) {
      return 'Server error. Please try again later.';
    }
    // Remove technical details for security
    return errorStr.replaceAll(RegExp(r'\{[^}]*\}'), '').trim();
  }
}
