import 'package:flutter/foundation.dart';

/// Simple logger utility for development and production
class AppLogger {
  static const String _prefix = '🔷 EVENTY';

  /// Log debug information (only in debug mode)
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $message${data != null ? ': $data' : ''}');
    }
  }

  /// Log info messages (only in debug mode)
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message${data != null ? ': $data' : ''}');
    }
  }

  /// Log warning messages (only in debug mode)
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [WARNING] $message${data != null ? ': $data' : ''}');
    }
  }

  /// Log error messages (works in both debug and release mode)
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix [ERROR] $message${error != null ? ': $error' : ''}');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
