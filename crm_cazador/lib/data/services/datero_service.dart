import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/datero_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de dateros (Cazador)
class DateroService {
  /// Obtener lista de dateros paginada
  static Future<PaginatedResponse<DateroModel>> getDateros({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await ApiService.get(
        '/cazador/dateros',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      // Reutilizamos PaginatedResponse pero el formato de data es diferente (data.dateros)
      final dataObj = responseData['data'] as Map<String, dynamic>? ?? {};
      final daterosList = dataObj['dateros'] as List<dynamic>? ?? [];
      final pagination = dataObj['pagination'] as Map<String, dynamic>? ?? {};

      return PaginatedResponse<DateroModel>(
        data: daterosList
            .map((item) => DateroModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        currentPage: pagination['current_page'] as int? ?? 1,
        totalPages: pagination['last_page'] as int? ?? 1,
        totalItems: pagination['total'] as int? ?? 0,
        perPage: pagination['per_page'] as int? ?? perPage,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            errorMessage ?? 'No tienes permiso para acceder a estos dateros');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Too Many Requests');
      }
      throw ApiException(
          errorMessage ?? 'Error al obtener dateros: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener datero por ID
  static Future<DateroModel> getDatero(int id) async {
    try {
      final response = await ApiService.get('/cazador/dateros/$id');
      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Datero no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            errorMessage ?? 'No tienes permiso para acceder a este datero');
      }
      throw ApiException(
          errorMessage ?? 'Error al obtener datero: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Crear nuevo datero
  static Future<DateroModel> createDatero(DateroModel datero) async {
    try {
      final response = await ApiService.post(
        '/cazador/dateros',
        data: datero.toCreateJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? specificError;
        
        // Intentar obtener el primer error de validación
        if (errors != null && errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final firstErrorValue = errors[firstErrorKey];
          
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            specificError = firstErrorValue.first.toString();
          } else if (firstErrorValue is String) {
            specificError = firstErrorValue;
          }
        }
        
        throw ApiException(
            specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(
          apiMessage ?? 'Error al crear datero: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar datero (PATCH)
  static Future<DateroModel> updateDatero(
    int id,
    DateroModel datero,
  ) async {
    try {
      final response = await ApiService.patch(
        '/cazador/dateros/$id',
        data: datero.toPartialJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Datero no encontrado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            apiMessage ?? 'No tienes permiso para acceder a este datero');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? specificError;
        
        // Intentar obtener el primer error de validación
        if (errors != null && errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final firstErrorValue = errors[firstErrorKey];
          
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            specificError = firstErrorValue.first.toString();
          } else if (firstErrorValue is String) {
            specificError = firstErrorValue;
          }
        }
        
        throw ApiException(
            specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(
          apiMessage ?? 'Error al actualizar datero: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}


