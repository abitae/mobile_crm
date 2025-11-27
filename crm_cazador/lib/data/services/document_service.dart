import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/document_search_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para búsqueda de documentos (DNI)
class DocumentService {
  /// Buscar datos por DNI
  /// 
  /// [documentType] debe ser 'dni' (solo DNI está soportado)
  /// [documentNumber] debe tener exactamente 8 dígitos
  static Future<DocumentSearchResponse> searchDocument({
    required String documentType,
    required String documentNumber,
  }) async {
    try {
      // Normalizar el tipo de documento a minúsculas
      final normalizedType = documentType.toLowerCase().trim();
      
      // Validar que solo se acepte DNI
      if (normalizedType != 'dni') {
        throw ApiException('Solo se permite búsqueda por DNI. Tipo recibido: $documentType');
      }

      // Sanitizar el número de documento (solo números)
      final sanitizedNumber = documentNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // Validar que el DNI tenga exactamente 8 dígitos
      if (sanitizedNumber.length != 8) {
        throw ApiException('El DNI debe tener exactamente 8 dígitos. Se recibieron ${sanitizedNumber.length} dígitos.');
      }

      // Validar que no esté vacío después de sanitizar
      if (sanitizedNumber.isEmpty) {
        throw ApiException('El número de documento no puede estar vacío');
      }

      final response = await ApiService.post(
        '/cazador/documents/search',
        data: {
          'document_type': normalizedType,
          'document_number': sanitizedNumber,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Verificar si la respuesta es exitosa
      final success = responseData['success'] as bool? ?? true;
      
      // Si no es exitosa, puede ser un error 409 (cliente registrado)
      // El servidor puede retornar 200 con success: false o 409
      if (!success) {
        final errors = responseData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors['client_registered'] == true) {
          // Cliente ya registrado - extraer información según documentación
          final advisor = errors['assigned_advisor'] as Map<String, dynamic>?;
          
          // Priorizar el mensaje dentro de errors, luego el mensaje general
          String? detailedMessage = errors['message'] as String?;
          
          if (detailedMessage == null || detailedMessage.isEmpty) {
            // Construir mensaje con información del asesor
            if (advisor != null) {
              final advisorName = advisor['name'] as String? ?? 'N/A';
              detailedMessage = 'Cliente registrado por el cazador responsable: $advisorName';
            } else {
              detailedMessage = responseData['message'] as String? ?? 
                  'El cliente ya está registrado en el sistema';
            }
          }
          
          throw ApiException(detailedMessage);
        }
        // Otro tipo de error en la respuesta
        throw ApiException(
          responseData['message'] as String? ?? 'Error en la búsqueda de documento'
        );
      }

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
        // Cliente ya registrado - incluir información del error según documentación
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? detailedMessage;
        
        if (errors != null && errors['client_registered'] == true) {
          // Priorizar el mensaje dentro de errors según documentación
          detailedMessage = errors['message'] as String?;
          
          if (detailedMessage == null || detailedMessage.isEmpty) {
            // Construir mensaje con información del asesor
            final advisor = errors['assigned_advisor'] as Map<String, dynamic>?;
            if (advisor != null) {
              final advisorName = advisor['name'] as String? ?? 'N/A';
              detailedMessage = 'Cliente registrado por el cazador responsable: $advisorName';
            } else {
              detailedMessage = errorMessage ?? 'El cliente ya está registrado en el sistema';
            }
          }
        } else {
          detailedMessage = errorMessage ?? 'El cliente ya está registrado en el sistema';
        }
        
        throw ApiException(detailedMessage);
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

