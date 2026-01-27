import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/activity_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de actividades de clientes
/// 
/// Endpoints disponibles:
/// - GET /clients/{client}/activities - Lista actividades con filtros y paginación
/// - POST /clients/{client}/activities - Crea una nueva actividad
/// - PUT/PATCH /clients/{client}/activities/{activity} - Actualiza una actividad
class ActivityService {
  /// Obtener actividades de un cliente usando include (método legacy)
  /// Usa GET /clients/{clientId} con include=activities
  /// Mantenido para compatibilidad
  static Future<List<ActivityModel>> getClientActivities(int clientId) async {
    try {
      debugPrint('📋 [ActivityService.getClientActivities] Solicitando actividades vía include para cliente: $clientId');
      final response = await ApiService.get(
        '/cazador/clients/$clientId',
        queryParameters: {'include': 'activities'},
      );
      
      debugPrint('📥 [ActivityService.getClientActivities] Respuesta recibida');
      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final clientData = dataObj?['client'] ?? dataObj ?? responseData;
      
      debugPrint('📥 [ActivityService.getClientActivities] clientData keys: ${clientData.keys.toList()}');
      
      // Intentar obtener actividades del cliente
      final activitiesData = clientData['activities'] as List<dynamic>?;
      debugPrint('📥 [ActivityService.getClientActivities] activitiesData: ${activitiesData?.length ?? 0} items');
      
      if (activitiesData != null && activitiesData.isNotEmpty) {
        debugPrint('📋 [ActivityService.getClientActivities] Primera actividad raw: ${activitiesData.first}');
        return activitiesData
            .map((json) {
              try {
                debugPrint('📋 [ActivityService.getClientActivities] Parseando: ${json['id']}');
                return ActivityModel.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                debugPrint('❌ [ActivityService.getClientActivities] Error al parsear: $e');
                debugPrint('❌ [ActivityService.getClientActivities] JSON: $json');
                debugPrint('❌ [ActivityService.getClientActivities] StackTrace: $stackTrace');
                rethrow;
              }
            })
            .toList();
      }
      
      debugPrint('⚠️ [ActivityService.getClientActivities] No se encontraron actividades');
      return [];
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }
      
      debugPrint('❌ [ActivityService.getClientActivities] DioException: ${e.message}, statusCode: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Cliente no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(errorMessage ?? 'Error al obtener actividades: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('❌ [ActivityService.getClientActivities] Error inesperado: $e');
      debugPrint('❌ [ActivityService.getClientActivities] StackTrace: $stackTrace');
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener lista paginada de actividades de un cliente con filtros
  /// Usa GET /clients/{client}/activities
  /// 
  /// Query params opcionales:
  /// - per_page: Elementos por página
  /// - status: Estado de la actividad
  /// - activity_type: Tipo de actividad
  /// - priority: Prioridad
  /// - start_date_from: Fecha inicio desde
  /// - start_date_to: Fecha inicio hasta
  /// - search: Búsqueda de texto
  static Future<PaginatedResponse<ActivityModel>> getClientActivitiesList(
    int clientId, {
    int perPage = 15,
    String? status,
    String? activityType,
    String? priority,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (activityType != null && activityType.isNotEmpty) {
        queryParams['activity_type'] = activityType;
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (startDateFrom != null) {
        queryParams['start_date_from'] = startDateFrom.toIso8601String().split('T')[0];
      }
      if (startDateTo != null) {
        queryParams['start_date_to'] = startDateTo.toIso8601String().split('T')[0];
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      debugPrint('📤 [ActivityService] Solicitando actividades: clientId=$clientId, queryParams=$queryParams');
      final response = await ApiService.get(
        '/cazador/clients/$clientId/activities',
        queryParameters: queryParams,
      );

      debugPrint('📥 [ActivityService] Respuesta recibida: statusCode=${response.statusCode}');
      debugPrint('📥 [ActivityService] Response data type: ${response.data.runtimeType}');

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('📥 [ActivityService] Response data keys: ${responseData.keys.toList()}');
      
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      debugPrint('📥 [ActivityService] dataObj: ${dataObj != null ? dataObj.keys.toList() : "null"}');

      // La respuesta según documentación tiene estructura:
      // { "data": { "activities": [...], "pagination": {...} } }
      List<dynamic> activitiesData = [];
      Map<String, dynamic>? pagination;

      if (dataObj != null) {
        debugPrint('📥 [ActivityService] dataObj contiene: ${dataObj.keys.toList()}');
        if (dataObj.containsKey('activities')) {
          activitiesData = dataObj['activities'] as List<dynamic>? ?? [];
          pagination = dataObj['pagination'] as Map<String, dynamic>?;
          debugPrint('✅ [ActivityService] Actividades encontradas en data.activities: ${activitiesData.length}');
        } else {
          debugPrint('⚠️ [ActivityService] dataObj no contiene "activities", buscando alternativas...');
          // Fallback: si no hay 'activities', intentar usar data directamente
          activitiesData = dataObj.values.first is List
              ? (dataObj.values.first as List<dynamic>)
              : [];
          pagination = dataObj['pagination'] as Map<String, dynamic>?;
          debugPrint('📥 [ActivityService] Actividades encontradas en fallback: ${activitiesData.length}');
        }
      } else {
        debugPrint('⚠️ [ActivityService] dataObj es null, usando estructura directa...');
        // Fallback: estructura directa
        activitiesData = responseData['activities'] as List<dynamic>? ?? [];
        pagination = responseData['pagination'] as Map<String, dynamic>?;
        debugPrint('📥 [ActivityService] Actividades encontradas en respuesta directa: ${activitiesData.length}');
      }

      debugPrint('📋 [ActivityService] Total actividades raw: ${activitiesData.length}');
      if (activitiesData.isNotEmpty) {
        debugPrint('📋 [ActivityService] Primera actividad raw: ${activitiesData.first}');
      }

      final activities = activitiesData
          .map((json) {
            try {
              debugPrint('📋 [ActivityService] Parseando actividad: ${json['id']}, title: ${json['title']}, activity_type: ${json['activity_type']}');
              final activity = ActivityModel.fromJson(json as Map<String, dynamic>);
              debugPrint('✅ [ActivityService] Actividad parseada: ID=${activity.id}, Title=${activity.title}, Type=${activity.activityType}');
              return activity;
            } catch (e, stackTrace) {
              debugPrint('❌ [ActivityService] Error al parsear actividad: $e');
              debugPrint('❌ [ActivityService] JSON keys: ${(json as Map).keys.toList()}');
              debugPrint('❌ [ActivityService] JSON completo: $json');
              debugPrint('❌ [ActivityService] StackTrace: $stackTrace');
              rethrow;
            }
          })
          .toList();
      
      debugPrint('✅ [ActivityService] Actividades parseadas exitosamente: ${activities.length}');
      if (activities.isNotEmpty) {
        debugPrint('📋 [ActivityService] Primera actividad parseada:');
        debugPrint('   - ID: ${activities.first.id}');
        debugPrint('   - Title: ${activities.first.title}');
        debugPrint('   - ActivityType: ${activities.first.activityType}');
        debugPrint('   - StartDate: ${activities.first.startDate}');
        debugPrint('   - Status: ${activities.first.status}');
      }

      return PaginatedResponse<ActivityModel>(
        data: activities,
        currentPage: pagination?['current_page'] as int? ?? 1,
        totalPages: pagination?['last_page'] as int? ?? 1,
        totalItems: pagination?['total'] as int? ?? 0,
        perPage: pagination?['per_page'] as int? ?? perPage,
      );
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
      }
      throw ApiException(errorMessage ?? 'Error al obtener actividades: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Crear una actividad para un cliente
  /// Usa POST /clients/{client}/activities
  /// 
  /// Campos requeridos en el body:
  /// - type: Tipo de actividad (string)
  /// - description: Descripción (string)
  /// 
  /// Campos opcionales:
  /// - activity_date: Fecha de la actividad (date)
  /// - notes: Notas adicionales (string)
  static Future<ActivityModel> createActivity(
    int clientId,
    ActivityModel activity,
  ) async {
    try {
      final response = await ApiService.post(
        '/cazador/clients/$clientId/activities',
        data: activity.toCreateJson(),
      );

      final responseData = response.data;
      
      // Manejar diferentes estructuras de respuesta
      Map<String, dynamic> activityData;
      
      if (responseData is Map<String, dynamic>) {
        final dataObj = responseData['data'] as Map<String, dynamic>?;
        if (dataObj != null) {
          // Intentar obtener 'activity' dentro de 'data'
          if (dataObj.containsKey('activity')) {
            activityData = dataObj['activity'] as Map<String, dynamic>;
          } else {
            // Si no hay 'activity', usar 'data' directamente
            activityData = dataObj;
          }
        } else {
          // Si no hay 'data', usar la respuesta completa
          activityData = responseData;
        }
      } else {
        throw ApiException('Formato de respuesta inválido');
      }

      // Asegurar que client_id esté presente (agregarlo si falta)
      // Esto previene el error "type 'Null' is not a subtype of type 'int'"
      if (!activityData.containsKey('client_id') || activityData['client_id'] == null) {
        activityData['client_id'] = clientId;
      }

      // Asegurar que campos requeridos tengan valores por defecto si vienen null
      if (activityData['title'] == null || activityData['title'].toString().isEmpty) {
        activityData['title'] = activity.title;
      }
      if (activityData['activity_type'] == null || activityData['activity_type'].toString().isEmpty) {
        activityData['activity_type'] = activity.activityType;
      }
      if (activityData['start_date'] == null || activityData['start_date'].toString().isEmpty) {
        if (activity.startDate != null) {
          activityData['start_date'] = activity.startDate!.toIso8601String();
        }
      }

      return ActivityModel.fromJson(activityData);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? specificError;
        if (errors != null && errors.isNotEmpty) {
          // Intentar obtener el primer error
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            specificError = firstError.first.toString();
          } else if (firstError is String) {
            specificError = firstError;
          }
        }
        throw ApiException(specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(apiMessage ?? 'No tienes permiso para crear actividades');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Cliente no encontrado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(apiMessage ?? 'Error al crear actividad: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar una actividad del cliente
  /// Usa PUT/PATCH /clients/{client}/activities/{activity}
  /// 
  /// Campos permitidos según documentación:
  /// - status: Estado de la actividad (string, opcional)
  /// - result: Resultado de la actividad (string, opcional)
  /// - notes: Notas (string, opcional)
  /// - start_date: Fecha de inicio (date, opcional)
  /// - assigned_to: ID del usuario asignado (int, opcional)
  static Future<ActivityModel> updateActivity(
    int clientId,
    int activityId,
    ActivityModel activity,
  ) async {
    try {
      final response = await ApiService.put(
        '/cazador/clients/$clientId/activities/$activityId',
        data: activity.toUpdateJson(),
      );

      final responseData = response.data;
      
      // Manejar diferentes estructuras de respuesta
      Map<String, dynamic> activityData;
      
      if (responseData is Map<String, dynamic>) {
        final dataObj = responseData['data'] as Map<String, dynamic>?;
        if (dataObj != null) {
          if (dataObj.containsKey('activity')) {
            activityData = dataObj['activity'] as Map<String, dynamic>;
          } else {
            activityData = dataObj;
          }
        } else {
          activityData = responseData;
        }
      } else {
        throw ApiException('Formato de respuesta inválido');
      }

      // Asegurar que client_id esté presente
      if (!activityData.containsKey('client_id') || activityData['client_id'] == null) {
        activityData['client_id'] = clientId;
      }

      return ActivityModel.fromJson(activityData);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String? specificError;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            specificError = firstError.first.toString();
          } else if (firstError is String) {
            specificError = firstError;
          }
        }
        throw ApiException(specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(apiMessage ?? 'No tienes permiso para actualizar esta actividad');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Actividad o cliente no encontrado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(apiMessage ?? 'Error al actualizar actividad: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}
