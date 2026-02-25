import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/exception_helper.dart';
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
      
      final rawData = response.data;
      if (rawData == null) {
        AppLogger.error('Respuesta sin datos', tag: 'DashboardService');
        throw ApiException('Respuesta inválida del servidor');
      }
      if (rawData is! Map<String, dynamic>) {
        AppLogger.error('Respuesta en formato inesperado', tag: 'DashboardService', data: {
          'data_type': rawData.runtimeType.toString(),
          'data_value': rawData.toString(),
        });
        throw ApiException('Respuesta inválida del servidor');
      }
      final responseData = rawData;
      if (responseData['success'] == false) {
        final message = responseData['message'] as String? ??
            'Error al obtener estadisticas del dashboard';
        throw ApiException(message);
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
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al obtener estadisticas del dashboard',
      );
    } catch (e, stackTrace) {
      AppLogger.error('❌ [DashboardService] Error inesperado', tag: 'DashboardService', 
        error: e, stackTrace: stackTrace);
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}
