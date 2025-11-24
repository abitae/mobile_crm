import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/project_model.dart';
import '../models/unit_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de proyectos (Cazador)
class ProjectService {
  /// Obtener lista de proyectos paginada
  static Future<PaginatedResponse<ProjectModel>> getProjects({
    int page = 1,
    int perPage = 15,
    String? search,
    String? projectType,
    String? loteType,
    String? stage,
    String? legalStatus,
    String? status,
    String? district,
    String? province,
    String? region,
    bool? hasAvailableUnits,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (projectType != null && projectType.isNotEmpty) {
        queryParams['project_type'] = projectType;
      }
      if (loteType != null && loteType.isNotEmpty) {
        queryParams['lote_type'] = loteType;
      }
      if (stage != null && stage.isNotEmpty) {
        queryParams['stage'] = stage;
      }
      if (legalStatus != null && legalStatus.isNotEmpty) {
        queryParams['legal_status'] = legalStatus;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (district != null && district.isNotEmpty) {
        queryParams['district'] = district;
      }
      if (province != null && province.isNotEmpty) {
        queryParams['province'] = province;
      }
      if (region != null && region.isNotEmpty) {
        queryParams['region'] = region;
      }
      if (hasAvailableUnits != null) {
        queryParams['has_available_units'] = hasAvailableUnits;
      }

      final response = await ApiService.get(
        '/cazador/projects',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      return PaginatedResponse.fromJson(
        responseData,
        (json) {
          if (json is Map<String, dynamic>) {
            return ProjectModel.fromJson(json);
          }
          throw Exception('Formato de proyecto inválido');
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
      throw ApiException(errorMessage ?? 'Error al obtener proyectos: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener proyecto por ID
  static Future<ProjectModel> getProject(int id) async {
    try {
      final response = await ApiService.get('/cazador/projects/$id');
      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final projectData = dataObj?['project'] ?? dataObj ?? responseData;

      return ProjectModel.fromJson(projectData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Proyecto no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(errorMessage ?? 'Error al obtener proyecto: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener unidades de un proyecto
  static Future<PaginatedResponse<UnitModel>> getProjectUnits({
    required int projectId,
    int page = 1,
    int perPage = 15,
    String? status,
    String? unitType,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    bool? onlyAvailable,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (unitType != null && unitType.isNotEmpty) {
        queryParams['unit_type'] = unitType;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }
      if (minArea != null) {
        queryParams['min_area'] = minArea;
      }
      if (maxArea != null) {
        queryParams['max_area'] = maxArea;
      }
      if (bedrooms != null) {
        queryParams['bedrooms'] = bedrooms;
      }
      if (onlyAvailable != null) {
        queryParams['only_available'] = onlyAvailable;
      }

      final response = await ApiService.get(
        '/cazador/projects/$projectId/units',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final units = dataObj?['units'] as List<dynamic>? ?? [];
      final pagination = dataObj?['pagination'] as Map<String, dynamic>? ?? {};

      return PaginatedResponse<UnitModel>(
        data: units.map((item) => UnitModel.fromJson(item as Map<String, dynamic>)).toList(),
        currentPage: pagination['current_page'] as int? ?? 1,
        totalPages: pagination['last_page'] as int? ?? 1,
        totalItems: pagination['total'] as int? ?? 0,
        perPage: pagination['per_page'] as int? ?? 15,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Proyecto no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(errorMessage ?? 'Error al obtener unidades: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

