import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/client_model.dart';
import '../models/api_response.dart';
import '../models/client_options.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de clientes (Cazador)
class ClientService {
  /// Obtener lista de clientes paginada
  static Future<PaginatedResponse<ClientModel>> getClients({
    int page = 1,
    int perPage = 15,
    String? search,
    String? status,
    String? type,
    String? source,
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

      final response = await ApiService.get(
        '/cazador/clients',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      return PaginatedResponse.fromJson(
        responseData,
        (json) {
          if (json is Map<String, dynamic>) {
            return ClientModel.fromJson(json);
          }
          throw Exception('Formato de cliente inválido');
        },
      );
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
      final response = await ApiService.post(
        '/cazador/clients',
        data: client.toCreateJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;

      return ClientModel.fromJson(clientData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(specificError ?? apiMessage ?? 'Error de validación');
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
      final response = await ApiService.patch(
        '/cazador/clients/$id',
        data: client.toPartialJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;

      return ClientModel.fromJson(clientData as Map<String, dynamic>);
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
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(apiMessage ?? 'Error al actualizar cliente: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
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

