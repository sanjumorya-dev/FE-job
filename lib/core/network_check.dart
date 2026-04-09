import 'dart:io';
import 'package:flutter/foundation.dart';

/// Network connectivity checker
class NetworkCheck {
  /// Check if device has internet connectivity
  static Future<bool> isConnected() async {
    try {
      // Try to reach Google's DNS servers (works globally)
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      debugPrint('Network check timeout');
      return false;
    } catch (e) {
      debugPrint('Network check error: $e');
      return false;
    }
    return false;
  }

  /// Execute a function only if network is available
  static Future<T?> runIfConnected<T>(Future<T> Function() fn) async {
    final connected = await isConnected();
    if (!connected) {
      debugPrint('No network connection available');
      return null;
    }
    return await fn();
  }

  /// Get user-friendly network error message
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    }
    if (error is TimeoutException ||
        (error is Exception && error.toString().contains('timeout'))) {
      return 'Connection timed out. Please try again.';
    }
    if (error is HttpException ||
        (error is Exception && error.toString().contains('HTTP'))) {
      return 'Server error. Please try again later.';
    }
    return 'Network error. Please check your connection.';
  }
}
