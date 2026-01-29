import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/client_model.dart';
import '../models/api_response.dart';
import '../models/client_options.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/logging/app_logger.dart';

/// Servicio para gestión de clientes (Cazador)
class ClientService {
  static Map<String, dynamic> _ensureCreateMode(
    Map<String, dynamic> payload,
    String? createMode,
  ) {
    final normalizedMode = (createMode ?? '').trim().isNotEmpty
        ? createMode!.trim().toLowerCase()
        : 'dni';
    payload['create_mode'] = normalizedMode;
    return payload;
  }

  static String? _buildDuplicateOwnerMessage(Map<String, dynamic>? duplicateOwner) {
    if (duplicateOwner == null) return null;
    final ownerName = duplicateOwner['name']?.toString().trim();
    final field = duplicateOwner['field']?.toString().trim();
    if (ownerName == null || ownerName.isEmpty || field == null || field.isEmpty) {
      return null;
    }
    if (field == 'phone') {
      return 'Telefono registrado por "$ownerName"';
    }
    if (field == 'document_number') {
      return 'DNI registrado por "$ownerName"';
    }
    return '$field registrado por "$ownerName"';
  }

  static String? _extractValidationMessage(
    Map<String, dynamic>? errors,
    String? apiMessage,
  ) {
    if (errors == null || errors.isEmpty) {
      return apiMessage;
    }

    final duplicateOwner = errors['duplicate_owner'] as Map<String, dynamic>?;
    final duplicateMessage = _buildDuplicateOwnerMessage(duplicateOwner);
    if (duplicateMessage != null) {
      return duplicateMessage;
    }

    final nestedErrors = errors['errors'];
    if (nestedErrors is Map<String, dynamic> && nestedErrors.isNotEmpty) {
      final firstError = nestedErrors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError is String) {
        return firstError;
      }
    }

    final firstError = errors.values.first;
    if (firstError is List && firstError.isNotEmpty) {
      return firstError.first.toString();
    }
    if (firstError is String) {
      return firstError;
    }

    return apiMessage;
  }

  /// Obtener lista de clientes paginada
  static Future<PaginatedResponse<ClientModel>> getClients({
    int page = 1,
    int perPage = 15,
    String? search,
    String? status,
    String? type,
    String? source,
    String? createType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (source != null && source.isNotEmpty) {
        queryParams['source'] = source;
      }
      // Manejar createType: si es null, no enviar el parámetro (mostrar todos)
      if (createType != null && createType.isNotEmpty) {
        queryParams['create_type'] = createType;
        AppLogger.debug('🔍 [ClientService] Filtro create_type aplicado: $createType', tag: 'ClientService');
      } else {
        AppLogger.debug('🔍 [ClientService] Filtro create_type: null (mostrar todos)', tag: 'ClientService');
      }

      AppLogger.apiRequest('GET', '/cazador/clients', queryParams: queryParams);
      
      final response = await ApiService.get(
        '/cazador/clients',
        queryParameters: queryParams,
      );

      final statusCode = response.statusCode ?? 200;
      AppLogger.apiResponse('GET', '/cazador/clients', statusCode);
      
      // Manejar diferentes formatos de respuesta de error
      dynamic responseData;
      try {
        responseData = response.data;
      } catch (e) {
        AppLogger.error('Error al obtener datos de respuesta', tag: 'ClientService', error: e);
        throw ApiException('Error al procesar respuesta del servidor');
      }
      
      // Verificar si hay un error de autenticación u otro error HTTP
      if (statusCode == 401) {
        String? errorMessage;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String?;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      
      if (statusCode >= 400) {
        String? errorMessage;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String?;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        throw ApiException(errorMessage ?? 'Error al obtener clientes (${statusCode})');
      }
      
      // Verificar que responseData sea un Map
      if (responseData is! Map<String, dynamic>) {
        AppLogger.error('Respuesta en formato inesperado', tag: 'ClientService', data: {
          'data_type': responseData.runtimeType.toString(),
          'data_value': responseData.toString(),
        });
        throw ApiException('Formato de respuesta inválido');
      }
      
      // Verificar si la respuesta indica un error (aunque el statusCode sea 200)
      if (responseData.containsKey('message') && !responseData.containsKey('data')) {
        final errorMessage = responseData['message'] as String?;
        if (errorMessage != null) {
          final lowerMessage = errorMessage.toLowerCase();
          if (lowerMessage.contains('unauthenticated') || 
              lowerMessage.contains('no autenticado') ||
              lowerMessage.contains('token')) {
            throw ApiException(errorMessage);
          }
        }
      }
      
      // Log detallado de la estructura recibida para debugging
      AppLogger.debug('📥 [ClientService] Respuesta recibida del endpoint', tag: 'ClientService', data: {
        'keys': responseData.keys.toList(),
        'has_data': responseData.containsKey('data'),
        'data_type': responseData['data']?.runtimeType.toString(),
        'success': responseData['success'],
        'message': responseData['message'],
      });
      
      // Verificar estructura de data
      final dataObj = responseData['data'];
      if (dataObj != null) {
        if (dataObj is Map<String, dynamic>) {
          final clientsList = dataObj['clients'];
          final paginationObj = dataObj['pagination'];
          
          AppLogger.debug('📊 [ClientService] Estructura de data', tag: 'ClientService', data: {
            'data_keys': dataObj.keys.toList(),
            'has_clients': dataObj.containsKey('clients'),
            'clients_type': clientsList?.runtimeType.toString(),
            'clients_count': clientsList is List ? (clientsList as List).length : null,
            'has_pagination': dataObj.containsKey('pagination'),
            'pagination_type': paginationObj?.runtimeType.toString(),
            'pagination_keys': paginationObj is Map ? (paginationObj as Map).keys.toList() : null,
          });
          
          // Log del primer cliente si existe para verificar estructura
          if (clientsList is List && clientsList.isNotEmpty) {
            final firstClient = clientsList.first;
            AppLogger.debug('👤 [ClientService] Primer cliente recibido', tag: 'ClientService', data: {
              'first_client_keys': firstClient is Map ? (firstClient as Map).keys.toList() : 'No es Map',
              'first_client_id': firstClient is Map ? (firstClient as Map)['id'] : null,
              'first_client_name': firstClient is Map ? (firstClient as Map)['name'] : null,
            });
          } else {
            AppLogger.debug('⚠️ [ClientService] Lista de clientes vacía o no es una lista', tag: 'ClientService', data: {
              'clients_list_type': clientsList?.runtimeType.toString(),
              'clients_list_value': clientsList?.toString(),
            });
          }
        } else {
          AppLogger.debug('⚠️ [ClientService] data no es un Map', tag: 'ClientService', data: {
            'data_type': dataObj.runtimeType.toString(),
            'data_value': dataObj.toString(),
          });
        }
      } else {
        AppLogger.debug('⚠️ [ClientService] No hay campo data en la respuesta', tag: 'ClientService');
      }
      
      try {
        return PaginatedResponse.fromJson(
          responseData,
          (json) {
            if (json is Map<String, dynamic>) {
              return ClientModel.fromJson(json);
            }
            throw Exception('Formato de cliente inválido');
          },
        );
      } catch (e, stackTrace) {
        AppLogger.error('Error al parsear respuesta de clientes', tag: 'ClientService', 
          error: e, stackTrace: stackTrace, data: {'response_structure': responseData});
        rethrow;
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Too Many Requests');
      }
      throw ApiException(errorMessage ?? 'Error al obtener clientes: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener cliente por ID
  static Future<ClientModel> getClient(int id) async {
    try {
      final response = await ApiService.get('/cazador/clients/$id');
      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;

      return ClientModel.fromJson(clientData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Cliente no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(errorMessage ?? 'No tienes permiso para acceder a este cliente');
      }
      throw ApiException(errorMessage ?? 'Error al obtener cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Crear nuevo cliente
  static Future<ClientModel> createClient(ClientModel client) async {
    try {
      // Construir payload respetando reglas de create_mode (dni|phone)
      final payload = _ensureCreateMode(client.toCreateJson(), client.createMode);
      debugPrint('📤 [ClientService] createClient payload: $payload');

      final response = await ApiService.post(
        '/cazador/clients',
        data: payload,
        queryParameters: {
          'create_mode': payload['create_mode'],
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == false) {
        debugPrint('❌ [ClientService] createClient success=false data=$responseData');
        final message = responseData['message'] as String? ??
            'Error al crear el cliente en Cazador';
        final errors = responseData['errors'] as Map<String, dynamic>?;
        final specificError = _extractValidationMessage(errors, message);
        throw ApiException(specificError ?? message, errors: errors);
      }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;

      if (clientData is! Map<String, dynamic>) {
        throw ApiException('Respuesta inválida del servidor al crear cliente');
      }
      if (clientData['id'] == null) {
        throw ApiException(
          responseData['message'] as String? ??
              'Respuesta inválida: id del cliente vacío',
        );
      }
      return ClientModel.fromJson(clientData);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }
      debugPrint('❌ [ClientService] createClient error status=${e.response?.statusCode} data=$responseData');

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = _extractValidationMessage(errors, apiMessage);
        throw ApiException(specificError ?? 'Error de validación', errors: errors, statusCode: 422);
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(apiMessage ?? 'Error al crear cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar cliente (PATCH)
  static Future<ClientModel> updateClient(
    int id,
    ClientModel client,
  ) async {
    try {
      final payload = _ensureCreateMode(client.toPartialJson(), client.createMode);
      debugPrint('📤 [ClientService] updateClient payload (id=$id): $payload');

      final response = await ApiService.patch(
        '/cazador/clients/$id',
        data: payload,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al actualizar el cliente en Cazador';
        throw ApiException(message);
      }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;

      if (clientData is! Map<String, dynamic>) {
        throw ApiException('Respuesta inválida del servidor al actualizar cliente');
      }
      if (clientData['id'] == null) {
        throw ApiException(
          responseData['message'] as String? ??
              'Respuesta inválida: id del cliente vacío',
        );
      }
      return ClientModel.fromJson(clientData);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }
      debugPrint('❌ [ClientService] updateClient error status=${e.response?.statusCode} data=$responseData');

      if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Cliente no encontrado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(apiMessage ?? 'No tienes permiso para acceder a este cliente');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = _extractValidationMessage(errors, apiMessage);
        throw ApiException(specificError ?? 'Error de validación', errors: errors, statusCode: 422);
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(apiMessage ?? 'Error al actualizar cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Validar payload de cliente sin persistir (POST /clients/validate)
  /// Lanza ApiException si hay errores de validación.
  static Future<void> validateClient(ClientModel client) async {
    try {
      final payload = _ensureCreateMode(client.toCreateJson(), client.createMode);
      debugPrint('📤 [ClientService] validateClient payload: $payload');

      final response = await ApiService.post(
        '/cazador/clients/validate',
        data: payload,
        queryParameters: {
          'create_mode': payload['create_mode'],
        },
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw ApiException('Respuesta vacía del servidor al validar cliente');
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      final valid = data?['valid'] as bool? ?? false;

      if (responseData['success'] == false && data == null) {
        final errors = responseData['errors'] as Map<String, dynamic>? ?? {};
        final message = _extractValidationMessage(errors, responseData['message'] as String?);
        throw ApiException(
          message ?? 'Error de validación de cliente',
          errors: errors,
          statusCode: 422,
        );
      }

      if (!valid) {
        final dataErrors = data?['errors'] as Map<String, dynamic>? ?? {};
        final duplicateOwner = data?['duplicate_owner'] as Map<String, dynamic>?;
        final errors = <String, dynamic>{
          'errors': dataErrors,
          if (duplicateOwner != null) 'duplicate_owner': duplicateOwner,
        };
        final message = _extractValidationMessage(errors, responseData['message'] as String?);
        throw ApiException(
          message ?? 'Error de validación de cliente',
          errors: errors,
          statusCode: 422,
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }
      debugPrint('❌ [ClientService] validateClient error status=${e.response?.statusCode} data=$responseData');
      if (e.response?.statusCode == 422 && responseData is Map<String, dynamic>) {
        final errors = responseData['errors'] as Map<String, dynamic>?;
        final specificError = _extractValidationMessage(errors, apiMessage);
        throw ApiException(
          specificError ?? 'Error de validación de cliente',
          errors: errors,
          statusCode: 422,
        );
      }
      throw ApiException(apiMessage ?? 'Error al validar cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado al validar cliente: ${e.toString()}');
    }
  }

  /// Eliminar cliente
  static Future<void> deleteClient(int id) async {
    try {
      await ApiService.delete('/cazador/clients/$id');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Cliente no encontrado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(apiMessage ?? 'No tienes permiso para acceder a este cliente');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(apiMessage ?? 'Error al eliminar cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener opciones para formularios
  static Future<ClientOptions> getOptions() async {
    try {
      final response = await ApiService.get('/cazador/clients/options');
      final responseData = response.data as Map<String, dynamic>;
      final optionsData = responseData['data'] ?? responseData;

      return ClientOptions.fromJson(optionsData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(apiMessage ?? 'Error al obtener opciones: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

