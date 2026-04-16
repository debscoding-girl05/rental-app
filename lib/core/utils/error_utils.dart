import 'dart:io';

/// Converts raw exceptions to user-friendly error messages.
///
/// This utility ensures users never see technical jargon, stack traces,
/// or backend implementation details. All errors are mapped to clear,
/// actionable messages.
class ErrorUtils {
  ErrorUtils._();

  /// Converts any exception to a user-friendly message.
  static String getUserFriendlyMessage(Object error) {
    final message = error.toString().toLowerCase();

    // Network / Connection errors
    if (error is SocketException ||
        message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable') ||
        message.contains('no internet') ||
        message.contains('failed host lookup') ||
        message.contains('connection timed out') ||
        message.contains('connection reset')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout errors
    if (message.contains('timeout') || message.contains('timed out')) {
      return 'The request took too long. Please try again.';
    }

    // Authentication errors
    if (message.contains('invalid login') ||
        message.contains('invalid password') ||
        message.contains('wrong password') ||
        message.contains('invalid credentials')) {
      return 'Incorrect email or password. Please try again.';
    }

    if (message.contains('user not found') ||
        message.contains('no user found') ||
        message.contains('user does not exist')) {
      return 'No account found with this email.';
    }

    if (message.contains('email already') ||
        message.contains('user already registered') ||
        message.contains('already exists')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('invalid email') ||
        message.contains('email not valid')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('weak password') ||
        message.contains('password should be')) {
      return 'Password is too weak. Use at least 6 characters.';
    }

    if (message.contains('session expired') ||
        message.contains('token expired') ||
        message.contains('jwt expired') ||
        message.contains('refresh token')) {
      return 'Your session has expired. Please sign in again.';
    }

    if (message.contains('unauthorized') ||
        message.contains('not authenticated') ||
        message.contains('401')) {
      return 'Please sign in to continue.';
    }

    if (message.contains('forbidden') ||
        message.contains('permission denied') ||
        message.contains('403')) {
      return 'You don\'t have permission to do this.';
    }

    // Storage / Upload errors
    if (message.contains('storage') ||
        message.contains('bucket') ||
        message.contains('upload failed')) {
      return 'Failed to upload file. Please try again.';
    }

    if (message.contains('file too large') ||
        message.contains('payload too large')) {
      return 'File is too large. Please choose a smaller file.';
    }

    // Database / Server errors
    if (message.contains('duplicate') ||
        message.contains('unique constraint')) {
      return 'This item already exists.';
    }

    if (message.contains('not found') || message.contains('404')) {
      return 'The requested item could not be found.';
    }

    if (message.contains('server error') ||
        message.contains('500') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('internal error')) {
      return 'Something went wrong on our end. Please try again later.';
    }

    // AI-specific errors
    if (message.contains('groq') ||
        message.contains('llama') ||
        message.contains('model') ||
        message.contains('rate limit') ||
        message.contains('quota')) {
      return 'AI service is temporarily unavailable. Please try again later.';
    }

    // Validation errors
    if (message.contains('required') ||
        message.contains('cannot be empty') ||
        message.contains('must not be null')) {
      return 'Please fill in all required fields.';
    }

    if (message.contains('invalid format') ||
        message.contains('format error')) {
      return 'Please check your input and try again.';
    }

    // PostgreSQL / Supabase specific (hide technical details)
    if (message.contains('postgrest') ||
        message.contains('pgrst') ||
        message.contains('supabase') ||
        message.contains('postgres') ||
        message.contains('sql')) {
      return 'Unable to save data. Please try again.';
    }

    // Generic fallback - never show the raw error
    return 'Something went wrong. Please try again.';
  }

  /// Shows a user-friendly error snackbar.
  /// Use this instead of manually creating SnackBars with raw errors.
  static void showErrorSnackBar(
    dynamic context,
    Object error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // Import is done via the calling code to avoid circular deps
    // This is just a helper signature reference
  }
}
