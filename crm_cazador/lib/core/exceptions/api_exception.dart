/// Excepción personalizada para errores de API
/// Soporta el nuevo formato del backend con code, error_id y details
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

  /// Crear ApiException desde respuesta de error del backend
  factory ApiException.fromResponse(
    Map<String, dynamic> responseData, {
    int? statusCode,
  }) {
    // Intentar extraer información del nuevo formato
    final code = responseData['code'] as String?;
    final errorId = responseData['error_id'] as String?;
    final details = responseData['details'] as Map<String, dynamic>?;
    final errors = responseData['errors'] as Map<String, dynamic>?;
    
    // Extraer mensaje
    String message = responseData['message'] as String? ?? 'Error desconocido';
    
    // Si hay detalles, intentar construir un mensaje más específico
    if (details != null && details.isNotEmpty) {
      final detailMessages = <String>[];
      details.forEach((key, value) {
        if (value is String) {
          detailMessages.add(value);
        } else if (value is List && value.isNotEmpty) {
          detailMessages.addAll(value.map((e) => e.toString()));
        }
      });
      if (detailMessages.isNotEmpty) {
        message = detailMessages.join(', ');
      }
    }
    
    // Si hay errors (formato Laravel), extraer el primer error
    if (errors != null && errors.isNotEmpty && message == 'Error desconocido') {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        message = firstError.first.toString();
      } else if (firstError is String) {
        message = firstError;
      }
    }

    return ApiException(
      message,
      statusCode: statusCode,
      errors: errors,
      code: code,
      errorId: errorId,
      details: details,
    );
  }

  /// Obtener mensaje amigable basado en el código de error
  String getFriendlyMessage() {
    if (code != null) {
      switch (code) {
        case 'VALIDATION_ERROR':
          return 'Por favor, verifica los datos ingresados.';
        case 'UNAUTHORIZED':
          return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
        case 'FORBIDDEN':
          return 'No tienes permiso para realizar esta acción.';
        case 'NOT_FOUND':
          return 'El recurso solicitado no fue encontrado.';
        case 'RATE_LIMIT_EXCEEDED':
          return 'Has realizado demasiadas solicitudes. Por favor, espera un momento.';
        case 'SERVER_ERROR':
          return 'Error en el servidor. Por favor, intenta más tarde.';
        case 'NETWORK_ERROR':
          return 'Error de conexión. Verifica tu conexión a internet.';
        default:
          return message;
      }
    }
    return message;
  }

  /// Verificar si el error es de validación
  bool get isValidationError => code == 'VALIDATION_ERROR' || statusCode == 422;

  /// Verificar si el error es de autenticación
  bool get isAuthenticationError => code == 'UNAUTHORIZED' || statusCode == 401;

  /// Verificar si el error es de autorización
  bool get isAuthorizationError => code == 'FORBIDDEN' || statusCode == 403;

  /// Verificar si el error es de red
  bool get isNetworkError => code == 'NETWORK_ERROR';

  @override
  String toString() => message;
}

