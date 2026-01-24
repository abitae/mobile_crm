import 'package:flutter/foundation.dart';

/// Niveles de logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger estructurado para la aplicación
class AppLogger {
  static const String _tagPrefix = '[CRM-Cazador]';
  
  /// Log de debug (solo en modo debug)
  static void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag: tag, data: data);
    }
  }

  /// Log de información
  static void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log de advertencia
  static void warning(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  static void error(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  /// Método interno para logging
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    
    // Prefijo con nivel y tag
    buffer.write('$_tagPrefix [${_getLevelEmoji(level)} ${level.name.toUpperCase()}]');
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    buffer.write(' $message');
    
    // Agregar datos adicionales
    if (data != null && data.isNotEmpty) {
      buffer.write('\n  Data: $data');
    }
    
    // Agregar error si existe
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    
    // Agregar stack trace si existe
    if (stackTrace != null) {
      buffer.write('\n  StackTrace: $stackTrace');
    }
    
    final logMessage = buffer.toString();
    
    // En producción, solo loggear errores y warnings
    if (kReleaseMode && (level == LogLevel.debug || level == LogLevel.info)) {
      return;
    }
    
    debugPrint(logMessage);
    
    // En modo debug, también imprimir con formato más legible
    if (kDebugMode) {
      _printFormatted(level, logMessage);
    }
  }

  /// Obtener emoji para el nivel
  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  /// Imprimir con formato legible en modo debug
  static void _printFormatted(LogLevel level, String message) {
    // En modo debug, el debugPrint ya es suficiente
    // Pero podemos agregar colores si se necesita en el futuro
  }

  /// Log de operación de API
  static void apiRequest(String method, String path, {Map<String, dynamic>? queryParams, Map<String, dynamic>? body}) {
    debug(
      '$method $path',
      tag: 'API',
      data: {
        if (queryParams != null) 'query': queryParams,
        if (body != null) 'body': body,
      },
    );
  }

  /// Log de respuesta de API
  static void apiResponse(String method, String path, int statusCode, {int? durationMs, Map<String, dynamic>? data}) {
    final level = statusCode >= 400 ? LogLevel.error : statusCode >= 300 ? LogLevel.warning : LogLevel.info;
    _log(
      level,
      '$method $path -> $statusCode',
      tag: 'API',
      data: {
        if (durationMs != null) 'duration_ms': durationMs,
        if (data != null && data.isNotEmpty) 'response': data,
      },
    );
  }

  /// Log de error de API
  static void apiError(String method, String path, Object error, {int? statusCode, StackTrace? stackTrace}) {
    _log(
      LogLevel.error,
      '$method $path -> Error',
      tag: 'API',
      data: {
        if (statusCode != null) 'status_code': statusCode,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de operación de caché
  static void cacheHit(String key) {
    debug('Cache HIT: $key', tag: 'Cache');
  }

  static void cacheMiss(String key) {
    debug('Cache MISS: $key', tag: 'Cache');
  }

  static void cachePut(String key) {
    debug('Cache PUT: $key', tag: 'Cache');
  }

  static void cacheInvalidate(String key) {
    debug('Cache INVALIDATE: $key', tag: 'Cache');
  }

  /// Log de operación de provider
  static void providerLoad(String providerName, {bool refresh = false}) {
    debug('Loading $providerName (refresh: $refresh)', tag: 'Provider');
  }

  static void providerSuccess(String providerName, {int? itemCount}) {
    info('$providerName loaded successfully${itemCount != null ? ' ($itemCount items)' : ''}', tag: 'Provider');
  }

  static void providerError(String providerName, String error) {
    _log(LogLevel.error, '$providerName failed: $error', tag: 'Provider');
  }
}
