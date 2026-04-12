import 'dart:developer' as dev;

/// Simple logging utility. Wraps [dev.log] for consistent formatting.
abstract final class AppLogger {
  /// Logs an informational message.
  static void info(String message, {String tag = 'LandlordOS'}) {
    dev.log('[INFO] $message', name: tag);
  }

  /// Logs a warning message.
  static void warning(String message, {String tag = 'LandlordOS'}) {
    dev.log('[WARN] $message', name: tag);
  }

  /// Logs an error with optional stack trace.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'LandlordOS',
  }) {
    dev.log(
      '[ERROR] $message',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
