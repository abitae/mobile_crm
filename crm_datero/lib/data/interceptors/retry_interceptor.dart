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
    if (_shouldNotRetry(err)) return handler.next(err);
    if (!_isRetryable(err)) return handler.next(err);
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) return handler.next(err);

    final delay = _calculateDelay(retryCount, err);
    await Future.delayed(delay);
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      if (e is DioException) return onError(e, handler);
      return handler.next(err);
    }
  }

  bool _shouldNotRetry(DioException err) {
    final path = err.requestOptions.path.toLowerCase();
    if (path.contains('/auth/login') || path.contains('/auth/refresh') || path.contains('/auth/logout')) return true;
    if (err.requestOptions.method != 'GET' && err.requestOptions.method != 'HEAD') {
      if (err.response?.statusCode != null && err.response!.statusCode! >= 400 && err.response!.statusCode! < 500 && err.response!.statusCode != 429) return true;
    }
    return false;
  }

  bool _isRetryable(DioException err) {
    if (err.response != null && err.response!.statusCode != null && retryableStatusCodes.contains(err.response!.statusCode)) return true;
    if (retryableExceptionTypes.contains(err.type)) return true;
    return false;
  }

  Duration _calculateDelay(int retryCount, DioException err) {
    final retryAfter = err.response?.headers.value('retry-after');
    if (retryAfter != null) {
      try {
        return Duration(seconds: int.parse(retryAfter));
      } catch (_) {}
    }
    final delaySeconds = baseDelay.inSeconds * (1 << retryCount);
    return Duration(seconds: delaySeconds.clamp(1, 30));
  }
}
