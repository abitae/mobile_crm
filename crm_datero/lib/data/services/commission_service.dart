import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/commission_model.dart';
import '../models/commission_stats_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para consulta de comisiones
class CommissionService {
  /// Obtener lista de comisiones paginada
  static Future<PaginatedResponse<CommissionModel>> getCommissions({
    int page = 1,
    int perPage = 15,
    String? status,
    String? commissionType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (commissionType != null && commissionType.isNotEmpty) {
        queryParams['commission_type'] = commissionType;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await ApiService.get(
        '/datero/commissions',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      // La respuesta viene con estructura: { "success": true, "data": { "commissions": [...], "pagination": {...} } }
      return PaginatedResponse.fromJson(
        responseData,
        (json) {
          // Si el json ya es un objeto comisión, parsearlo directamente
          if (json is Map<String, dynamic>) {
            return CommissionModel.fromJson(json);
          }
          throw Exception('Formato de comisión inválido');
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
      throw ApiException(errorMessage ?? 'Error al obtener comisiones: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener comisión por ID
  static Future<CommissionModel> getCommission(int id) async {
    try {
      final response = await ApiService.get('/datero/commissions/$id');
      final responseData = response.data as Map<String, dynamic>;
      // Según documentación: { "success": true, "data": { "commission": {...} } }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final commissionData = dataObj?['commission'] ?? dataObj ?? responseData;

      return CommissionModel.fromJson(commissionData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Comisión no encontrada');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(errorMessage ?? 'No tienes permiso para acceder a esta comisión');
      }
      throw ApiException(errorMessage ?? 'Error al obtener comisión: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de comisiones
  static Future<CommissionStatsModel> getStats() async {
    try {
      final response = await ApiService.get('/datero/commissions/stats');
      final responseData = response.data as Map<String, dynamic>;
      // Según documentación: { "success": true, "data": { "stats": {...} } }
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final statsData = dataObj?['stats'] ?? dataObj ?? responseData;

      return CommissionStatsModel.fromJson(statsData as Map<String, dynamic>);
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
      throw ApiException(errorMessage ?? 'Error al obtener estadísticas: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

