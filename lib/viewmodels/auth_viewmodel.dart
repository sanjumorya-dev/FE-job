import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/user_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  // In-memory OTP store for demo purposes (mobile -> otp)
  // Previously used an in-memory OTP store for demo; now use server APIs.

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Normalizes mobile numbers by ensuring a leading country code.
  String _withCountryCode(String mobile, String countryCode) {
    if (mobile.trim().isEmpty) return mobile;
    final m = mobile.trim();
    if (m.startsWith('+')) return m;
    // Ensure countryCode starts with '+'
    final cc = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    return '$cc$m';
  }

  // Check if user is already logged in (persistence)
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, fetch user profile
        final user = await _userService.getProfile();
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String mobileNumber, String password,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formatted = _withCountryCode(mobileNumber, countryCode);
      _currentUser = await _authService.login(formatted, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.updateProfile(payload);
      // Refresh
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Sends an OTP to [mobileNumber]. This is a simulated implementation
  /// Calls backend to request an OTP be sent to the given mobile number.
  Future<bool> sendOtp(String mobileNumber,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final formatted = _withCountryCode(mobileNumber, countryCode);
      final ok = await _authService.sendOtp(formatted);
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyOtp(String mobileNumber, String otp,
      {String countryCode = '+91'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final formatted = _withCountryCode(mobileNumber, countryCode);
      final token = await _authService.verifyOtp(formatted, otp);
      _isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Simulated password reset. In production, call your backend.
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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
