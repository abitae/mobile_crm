import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/datero_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/exception_helper.dart';

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
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al obtener los dateros';
        throw ApiException(message);
      }
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
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al obtener los dateros',
      );
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
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al obtener el datero';
        throw ApiException(message);
      }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al obtener el datero',
      );
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
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al registrar el datero';
        throw ApiException(message);
      }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al registrar el datero',
      );
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
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al actualizar el datero';
        throw ApiException(message);
      }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final userData = dataObj?['user'] ?? dataObj ?? responseData;

      return DateroModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al actualizar el datero',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}


