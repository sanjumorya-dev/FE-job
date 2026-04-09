/// Input validation and sanitization utilities

class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional in this app
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validate mobile number (Indian format: 10 digits starting with 6-9)
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    final trimmed = value.trim();
    // Remove any leading + or country code for validation
    final cleanNumber = trimmed.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length != 10) {
      return 'Mobile number must be 10 digits';
    }

    if (!RegExp(r'^[6-9]').hasMatch(cleanNumber)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (value.length > 50) {
      return 'Password must not exceed 50 characters';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    return null;
  }

  /// Validate password confirmation matches
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate name (basic sanitization)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmed.length > 100) {
      return 'Name must not exceed 100 characters';
    }

    // Check for invalid characters (allow letters, numbers, spaces, and basic punctuation)
    if (!RegExp(r"^[a-zA-Z0-9\s\.\-']+").hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  /// Validate Aadhar number (12 digits)
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Aadhar is optional
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length != 12) {
      return 'Aadhar number must be 12 digits';
    }

    return null;
  }

  /// Validate pincode (Indian format: 6 digits)
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length != 6) {
      return 'Pincode must be 6 digits';
    }

    return null;
  }

  /// Validate required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  /// Validate salary/numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    if (number > 1000000) {
      return '$fieldName seems too high';
    }

    return null;
  }

  /// Validate integer in range
  static String? validateIntRange(int? value, int min, int max, String label) {
    if (value == null) {
      return '$label is required';
    }
    if (value < min || value > max) {
      return '$label must be between $min and $max';
    }
    return null;
  }

  /// Sanitize string input (prevent XSS-like injection)
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .trim();
  }

  /// Validate country code format
  static String? validateCountryCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Default will be used
    }

    final trimmed = value.trim();
    if (!trimmed.startsWith('+')) {
      return 'Country code must start with +';
    }

    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty || digits.length > 4) {
      return 'Country code must be 1-4 digits after +';
    }

    return null;
  }
}

/// Validation result for form fields
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({required this.isValid, this.error});

  factory ValidationResult.success() => const ValidationResult(isValid: true);
  factory ValidationResult.failure(String error) =>
      ValidationResult(isValid: false, error: error);
}
