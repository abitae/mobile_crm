import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/project_model.dart';
import '../models/unit_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de proyectos (Cazador)
class ProjectService {
  // Caché simple en memoria para evitar llamadas duplicadas
  static final Map<String, _CachedResponse> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  /// Limpiar caché expirado
  static void _cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => now.difference(value.timestamp) > _cacheDuration);
  }
  
  /// Obtener clave de caché para unidades
  static String _getUnitsCacheKey(int projectId, int page, int perPage) {
    return 'units_$projectId\_$page\_$perPage';
  }
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

  /// Obtener proyecto por ID con unidades disponibles paginadas
  /// 
  /// Según la documentación:
  /// - `units_per_page`: Unidades por página (máximo 100, por defecto 15)
  /// - `include_units`: Incluir unidades en la respuesta (por defecto true)
  static Future<ProjectModel> getProject(
    int id, {
    int? unitsPerPage,
    bool? includeUnits,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (unitsPerPage != null) {
        queryParams['units_per_page'] = unitsPerPage.clamp(1, 100);
      }
      if (includeUnits != null) {
        queryParams['include_units'] = includeUnits;
      }

      final response = await ApiService.get(
        '/cazador/projects/$id',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
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

      if (e.response?.statusCode == 400) {
        throw ApiException(errorMessage ?? 'ID de proyecto inválido');
      } else if (e.response?.statusCode == 404) {
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

  /// Obtener unidades disponibles de un proyecto
  /// 
  /// Según la documentación:
  /// - Solo devuelve unidades con estado "disponible"
  /// - Las unidades se ordenan primero por manzana (ascendente) y luego por número de unidad (ascendente)
  /// - Solo acepta parámetros de paginación: `per_page` (máximo 100, por defecto 15) y `page`
  static Future<PaginatedResponse<UnitModel>> getProjectUnits({
    required int projectId,
    int page = 1,
    int perPage = 15,
    bool useCache = true,
  }) async {
    try {
      // Limpiar caché expirado
      _cleanExpiredCache();
      
      // Verificar caché si está habilitado
      if (useCache) {
        final cacheKey = _getUnitsCacheKey(projectId, page, perPage);
        final cached = _cache[cacheKey];
        if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheDuration) {
          return cached.data as PaginatedResponse<UnitModel>;
        }
      }
      
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage.clamp(1, 100),
      };

      final response = await ApiService.get(
        '/cazador/projects/$projectId/units',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Según la documentación, la estructura es:
      // {
      //   "success": true,
      //   "message": "...",
      //   "data": {
      //     "project": {...},
      //     "units": [...],
      //     "pagination": {...}
      //   }
      // }
      
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      
      if (dataObj == null) {
        throw ApiException('Respuesta inválida: no se encontró el objeto data');
      }
      
      // Obtener unidades según la documentación: data.units
      final units = dataObj['units'] as List<dynamic>?;
      
      if (units == null) {
        throw ApiException('Respuesta inválida: no se encontró el array units');
      }
      
      // Obtener paginación según la documentación: data.pagination
      final pagination = dataObj['pagination'] as Map<String, dynamic>? ?? {};
      
      // Parsear unidades de forma optimizada usando map con manejo de errores
      final parsedUnits = units
          .whereType<Map<String, dynamic>>()
          .map((unitData) {
            try {
              return UnitModel.fromJson(unitData);
            } catch (e) {
              // Log error solo en desarrollo, continuar con las demás unidades
              if (const bool.fromEnvironment('dart.vm.product') == false) {
                print('⚠️ [ProjectService] Error al parsear unidad: $e');
              }
              return null;
            }
          })
          .whereType<UnitModel>()
          .toList();
      
      final result = PaginatedResponse<UnitModel>(
        data: parsedUnits,
        currentPage: pagination['current_page'] as int? ?? 1,
        totalPages: pagination['last_page'] as int? ?? 1,
        totalItems: pagination['total'] as int? ?? 0,
        perPage: pagination['per_page'] as int? ?? 15,
      );
      
      // Guardar en caché si está habilitado
      if (useCache) {
        final cacheKey = _getUnitsCacheKey(projectId, page, perPage);
        _cache[cacheKey] = _CachedResponse(
          data: result,
          timestamp: DateTime.now(),
        );
      }
      
      return result;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 400) {
        throw ApiException(errorMessage ?? 'ID de proyecto inválido');
      } else if (e.response?.statusCode == 404) {
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
  
  /// Invalidar caché de unidades de un proyecto
  static void invalidateUnitsCache(int projectId) {
    _cache.removeWhere((key, value) => key.startsWith('units_$projectId\_'));
  }
  
  /// Limpiar todo el caché
  static void clearCache() {
    _cache.clear();
  }
}

/// Clase auxiliar para el caché
class _CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  
  _CachedResponse({
    required this.data,
    required this.timestamp,
  });
}

