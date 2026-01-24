import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/activity_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de actividades de clientes
class ActivityService {
  /// Crear una actividad para un cliente
  static Future<ActivityModel> createActivity(
    int clientId,
    ActivityModel activity,
  ) async {
    try {
      final response = await ApiService.post(
        '/cazador/clients/$clientId/activities',
        data: activity.toCreateJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final activityData = dataObj?['activity'] ?? dataObj ?? responseData;

      return ActivityModel.fromJson(activityData as Map<String, dynamic>);
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
}
