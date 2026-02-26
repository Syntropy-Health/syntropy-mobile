import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  static void _log(LogLevel level, String message, String? tag) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$timestamp [$levelStr]$tagStr $message');
  }
}
