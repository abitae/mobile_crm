import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger estructurado para la aplicación Datero
class AppLogger {
  static const String _tagPrefix = '[CRM-Datero]';

  static void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag: tag, data: data);
    }
  }

  static void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  static void warning(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.write('$_tagPrefix [${_getLevelEmoji(level)} ${level.name.toUpperCase()}]');
    if (tag != null) buffer.write(' [$tag]');
    buffer.write(' $message');
    if (data != null && data.isNotEmpty) buffer.write('\n  Data: $data');
    if (error != null) buffer.write('\n  Error: $error');
    if (stackTrace != null) buffer.write('\n  StackTrace: $stackTrace');
    final logMessage = buffer.toString();
    if (kReleaseMode && (level == LogLevel.debug || level == LogLevel.info)) return;
    debugPrint(logMessage);
  }

  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return '🔍';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warning: return '⚠️';
      case LogLevel.error: return '❌';
    }
  }

  static void apiRequest(String method, String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body}) {
    debug('$method $path', tag: 'API', data: {
      if (queryParams != null) 'query': queryParams,
      if (body != null) 'body': body,
    });
  }

  static void apiResponse(String method, String path, int statusCode, {int? durationMs, Map<String, dynamic>? data}) {
    final level = statusCode >= 400 ? LogLevel.error : statusCode >= 300 ? LogLevel.warning : LogLevel.info;
    _log(level, '$method $path -> $statusCode', tag: 'API', data: {
      if (durationMs != null) 'duration_ms': durationMs,
      if (data != null && data.isNotEmpty) 'response': data,
    });
  }

  static void apiError(String method, String path, Object error, {int? statusCode, StackTrace? stackTrace}) {
    _log(LogLevel.error, '$method $path -> Error', tag: 'API', data: {if (statusCode != null) 'status_code': statusCode}, error: error, stackTrace: stackTrace);
  }
}
