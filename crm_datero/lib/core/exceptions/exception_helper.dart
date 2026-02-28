import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Helper para convertir DioException a ApiException
class ExceptionHelper {
  static ApiException fromDioException(DioException e, {String? defaultMessage}) {
    final responseData = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (responseData is Map<String, dynamic>) {
      try {
        return ApiException.fromResponse(responseData, statusCode: statusCode);
      } catch (_) {}
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Tiempo de espera agotado. Verifica tu conexión a internet.',
        statusCode: statusCode,
        code: 'NETWORK_ERROR',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        'Error de conexión. Verifica tu conexión a internet.',
        statusCode: statusCode,
        code: 'NETWORK_ERROR',
      );
    }

    String? message = defaultMessage;
    Map<String, dynamic>? errors;
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] as String?;
      errors = responseData['errors'] as Map<String, dynamic>?;
    }

    switch (statusCode) {
      case 400:
        return ApiException(message ?? 'Solicitud inválida', statusCode: statusCode, errors: errors, code: 'BAD_REQUEST');
      case 401:
        return ApiException(message ?? 'Usuario no autenticado', statusCode: statusCode, errors: errors, code: 'UNAUTHORIZED');
      case 403:
        return ApiException(message ?? 'No tienes permiso para realizar esta acción', statusCode: statusCode, errors: errors, code: 'FORBIDDEN');
      case 404:
        return ApiException(message ?? 'Recurso no encontrado', statusCode: statusCode, errors: errors, code: 'NOT_FOUND');
      case 409:
        return ApiException(message ?? 'Conflicto: el recurso ya existe', statusCode: statusCode, errors: errors, code: 'CONFLICT');
      case 422:
        String? validationMessage = message;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) validationMessage = firstError.first.toString();
          else if (firstError is String) validationMessage = firstError;
        }
        return ApiException(validationMessage ?? 'Error de validación', statusCode: statusCode, errors: errors, code: 'VALIDATION_ERROR');
      case 429:
        return ApiException(message ?? 'Has realizado demasiadas solicitudes. Por favor, espera un momento.', statusCode: statusCode, errors: errors, code: 'RATE_LIMIT_EXCEEDED');
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(message ?? 'Error en el servidor. Por favor, intenta más tarde.', statusCode: statusCode, errors: errors, code: 'SERVER_ERROR');
      default:
        return ApiException(message ?? defaultMessage ?? 'Error desconocido: ${e.message ?? e.type.toString()}', statusCode: statusCode, errors: errors);
    }
  }
}
