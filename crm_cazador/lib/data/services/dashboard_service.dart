import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/logging/app_logger.dart';

/// Modelo de estadísticas del dashboard
class DashboardStats {
  final ClientsStats clients;
  final DaterosStats dateros;
  final ReservationsStats reservations;

  DashboardStats({
    required this.clients,
    required this.dateros,
    required this.reservations,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return DashboardStats(
      clients: ClientsStats.fromJson(data['clients'] as Map<String, dynamic>? ?? {}),
      dateros: DaterosStats.fromJson(data['dateros'] as Map<String, dynamic>? ?? {}),
      reservations: ReservationsStats.fromJson(data['reservations'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ClientsStats {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byType;

  ClientsStats({
    required this.total,
    required this.byStatus,
    required this.byType,
  });

  factory ClientsStats.fromJson(Map<String, dynamic> json) {
    return ClientsStats(
      total: json['total'] as int? ?? 0,
      byStatus: (json['by_status'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      byType: (json['by_type'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }
}

class DaterosStats {
  final int total;
  final int active;
  final int inactive;

  DaterosStats({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory DaterosStats.fromJson(Map<String, dynamic> json) {
    return DaterosStats(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      inactive: json['inactive'] as int? ?? 0,
    );
  }
}


class ReservationsStats {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byPaymentStatus;

  ReservationsStats({
    required this.total,
    required this.byStatus,
    required this.byPaymentStatus,
  });

  factory ReservationsStats.fromJson(Map<String, dynamic> json) {
    return ReservationsStats(
      total: json['total'] as int? ?? 0,
      byStatus: (json['by_status'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      byPaymentStatus: (json['by_payment_status'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }
}

/// Servicio para obtener estadísticas del dashboard
class DashboardService {
  /// Obtener estadísticas del dashboard
  static Future<DashboardStats> getStats() async {
    try {
      AppLogger.debug('📤 [DashboardService] Solicitando estadísticas del dashboard');
      final response = await ApiService.get('/cazador/dashboard/stats');
      
      AppLogger.debug('📥 [DashboardService] Respuesta recibida: ${response.statusCode}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      if (responseData == null) {
        AppLogger.error('Respuesta sin datos', tag: 'DashboardService');
        throw ApiException('Respuesta inválida del servidor');
      }
      
      AppLogger.debug('📊 [DashboardService] Estructura de respuesta', tag: 'DashboardService', data: {
        'keys': responseData.keys.toList(),
        'has_data': responseData.containsKey('data'),
      });
      
      final stats = DashboardStats.fromJson(responseData);
      AppLogger.debug('✅ [DashboardService] Estadísticas parseadas exitosamente');
      return stats;
    } on DioException catch (e, stackTrace) {
      AppLogger.error('❌ [DashboardService] Error de red', tag: 'DashboardService', 
        error: e, stackTrace: stackTrace, data: {
          'status_code': e.response?.statusCode,
          'response_data': e.response?.data,
        });
      
      final responseData = e.response?.data;
      String? errorMessage;
      
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }
      
      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Endpoint de dashboard no encontrado');
      } else if (e.response?.statusCode == 500) {
        throw ApiException(errorMessage ?? 'Error interno del servidor');
      }
      
      throw ApiException(
        errorMessage ?? 'Error al obtener estadísticas: ${e.message}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('❌ [DashboardService] Error inesperado', tag: 'DashboardService', 
        error: e, stackTrace: stackTrace);
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}
