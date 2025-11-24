import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/document_search_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para búsqueda de documentos (DNI/RUC)
class DocumentService {
  /// Buscar datos por DNI/RUC
  /// 
  /// [documentType] debe ser 'dni' o 'ruc'
  /// [documentNumber] debe tener 8 dígitos para DNI o 11 para RUC
  static Future<DocumentSearchResponse> searchDocument({
    required String documentType,
    required String documentNumber,
  }) async {
    try {
      // Sanitizar el número de documento (solo números)
      final sanitizedNumber = documentNumber.replaceAll(RegExp(r'[^0-9]'), '');

      final response = await ApiService.post(
        '/datero/documents/search',
        data: {
          'document_type': documentType,
          'document_number': sanitizedNumber,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;

      if (dataObj == null) {
        throw ApiException('Respuesta inválida del servidor');
      }

      return DocumentSearchResponse.fromJson(dataObj);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 409) {
        // Cliente ya registrado - incluir información del error
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? detailedMessage = errorMessage;
        if (errors != null && errors['client_registered'] == true) {
          final advisor = errors['assigned_advisor'] as Map<String, dynamic>?;
          if (advisor != null) {
            final advisorName = advisor['name'] as String? ?? 'N/A';
            detailedMessage = 'Cliente registrado por el cazador responsable: $advisorName';
          } else {
            detailedMessage = errors['message'] as String? ?? errorMessage;
          }
        }
        throw ApiException(detailedMessage ?? 'El cliente ya está registrado en el sistema');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'No se encontró información para el documento proporcionado');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        }
        throw ApiException(errorMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Límite de solicitudes excedido. Intenta más tarde.');
      }
      throw ApiException(errorMessage ?? 'Error al buscar documento: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

