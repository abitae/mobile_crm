/// Excepción personalizada para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final String? code;
  final String? errorId;
  final Map<String, dynamic>? details;

  ApiException(
    this.message, {
    this.statusCode,
    this.errors,
    this.code,
    this.errorId,
    this.details,
  });

  factory ApiException.fromResponse(Map<String, dynamic> responseData, {int? statusCode}) {
    final code = responseData['code'] as String?;
    final errorId = responseData['error_id'] as String?;
    final details = responseData['details'] as Map<String, dynamic>?;
    final errors = responseData['errors'] as Map<String, dynamic>?;
    String message = responseData['message'] as String? ?? 'Error desconocido';
    if (details != null && details.isNotEmpty) {
      final list = <String>[];
      details.forEach((k, v) {
        if (v is String) list.add(v);
        else if (v is List && v.isNotEmpty) list.addAll(v.map((e) => e.toString()));
      });
      if (list.isNotEmpty) message = list.join(', ');
    }
    if (errors != null && errors.isNotEmpty && message == 'Error desconocido') {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) message = first.first.toString();
      else if (first is String) message = first;
    }
    return ApiException(message, statusCode: statusCode, errors: errors, code: code, errorId: errorId, details: details);
  }

  String getFriendlyMessage() {
    if (code != null) {
      switch (code) {
        case 'VALIDATION_ERROR': return 'Por favor, verifica los datos ingresados.';
        case 'UNAUTHORIZED': return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
        case 'FORBIDDEN': return 'No tienes permiso para realizar esta acción.';
        case 'NOT_FOUND': return 'El recurso solicitado no fue encontrado.';
        case 'RATE_LIMIT_EXCEEDED': return 'Has realizado demasiadas solicitudes. Por favor, espera un momento.';
        case 'SERVER_ERROR': return 'Error en el servidor. Por favor, intenta más tarde.';
        case 'NETWORK_ERROR': return 'Error de conexión. Verifica tu conexión a internet.';
        default: return message;
      }
    }
    return message;
  }

  bool get isValidationError => code == 'VALIDATION_ERROR' || statusCode == 422;
  bool get isAuthenticationError => code == 'UNAUTHORIZED' || statusCode == 401;
  bool get isAuthorizationError => code == 'FORBIDDEN' || statusCode == 403;
  bool get isNetworkError => code == 'NETWORK_ERROR';

  @override
  String toString() => message;
}

