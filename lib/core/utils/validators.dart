/// Common form validators for text fields.
abstract final class Validators {
  /// Returns an error message if the value is null or empty.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  /// Validates a basic email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Validates that the value is a positive number.
  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    final number = num.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Enter a valid positive number.';
    }
    return null;
  }

  /// Validates a phone number (basic: digits, spaces, +, dashes).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^[\d\s\+\-()]{7,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number.';
    }
    return null;
  }
}
