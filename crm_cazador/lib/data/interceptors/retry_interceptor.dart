import 'package:dio/dio.dart';

/// Interceptor para retry automático con backoff exponencial
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // No hacer retry en ciertos casos
    if (_shouldNotRetry(err)) {
      return handler.next(err);
    }

    // Verificar si es un error retryable
    if (!_isRetryable(err)) {
      return handler.next(err);
    }

    // Obtener número de intentos actual
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Calcular delay con backoff exponencial
    final delay = _calculateDelay(retryCount, err);

    // Esperar antes de reintentar
    await Future.delayed(delay);

    // Actualizar contador de intentos
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Reintentar la petición
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      // Si el retry falla, continuar con el siguiente intento o propagar el error
      if (e is DioException) {
        return onError(e, handler);
      }
      return handler.next(err);
    }
  }

  /// Verificar si NO se debe hacer retry
  bool _shouldNotRetry(DioException err) {
    final path = err.requestOptions.path.toLowerCase();
    
    // No hacer retry en endpoints de autenticación
    if (path.contains('/auth/login') || 
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout')) {
      return true;
    }

    // No hacer retry en métodos que no son idempotentes (excepto GET)
    if (err.requestOptions.method != 'GET' && 
        err.requestOptions.method != 'HEAD') {
      // Solo hacer retry en POST/PUT/PATCH si el error es de red, no de validación
      if (err.response?.statusCode != null && 
          err.response!.statusCode! >= 400 && 
          err.response!.statusCode! < 500 &&
          err.response!.statusCode != 429) {
        return true;
      }
    }

    return false;
  }

  /// Verificar si el error es retryable
  bool _isRetryable(DioException err) {
    // Verificar códigos de estado retryable
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
        return true;
      }
    }

    // Verificar tipos de excepción retryable
    if (retryableExceptionTypes.contains(err.type)) {
      return true;
    }

    return false;
  }

  /// Calcular delay con backoff exponencial
  Duration _calculateDelay(int retryCount, DioException err) {
    // Si hay header Retry-After, usarlo
    final retryAfter = err.response?.headers.value('retry-after');
    if (retryAfter != null) {
      try {
        final seconds = int.parse(retryAfter);
        return Duration(seconds: seconds);
      } catch (e) {
        // Si no se puede parsear, continuar con backoff exponencial
      }
    }

    // Backoff exponencial: 1s, 2s, 4s, 8s...
    final delaySeconds = baseDelay.inSeconds * (1 << retryCount);
    return Duration(seconds: delaySeconds.clamp(1, 30)); // Máximo 30 segundos
  }
}
