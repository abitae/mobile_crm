import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'api_service.dart';
import '../models/reservation_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/exception_helper.dart';
import '../../core/logging/app_logger.dart';

/// Servicio para gestión de reservas (Cazador)
class ReservationService {
  /// Obtener lista de reservas paginada con filtros
  /// El filtrado por `advisor_id` es automático en el backend según el usuario autenticado.
  static Future<PaginatedResponse<ReservationModel>> getReservations({
    int page = 1,
    int perPage = 15,
    String? search,
    String? status,
    String? paymentStatus,
    int? projectId,
    int? clientId,
    int? advisorId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage.clamp(1, 100),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['payment_status'] = paymentStatus;
      }
      if (projectId != null) {
        queryParams['project_id'] = projectId;
      }
      if (clientId != null) {
        queryParams['client_id'] = clientId;
      }
      if (advisorId != null) {
        queryParams['advisor_id'] = advisorId;
      }

      debugPrint('📤 [ReservationService] Solicitando reservas: page=$page, perPage=$perPage');
      
      final response = await ApiService.get(
        '/cazador/reservations',
        queryParameters: queryParams,
      );

      // Log para debugging
      debugPrint('📥 [ReservationService] Respuesta recibida: ${response.statusCode}');
      debugPrint('📥 [ReservationService] Headers: ${response.headers}');
      
          // Verificar que la respuesta tenga datos
          if (response.data == null) {
            AppLogger.error('Respuesta sin datos', tag: 'ReservationService');
            throw ApiException('Respuesta vacía del servidor');
          }
          
          final responseData = response.data as Map<String, dynamic>?;
          
          if (responseData == null) {
            AppLogger.error('Respuesta no es un Map', tag: 'ReservationService', data: {'data': response.data});
            throw ApiException('Respuesta inválida: formato de datos incorrecto');
          }
      
      // Verificar estructura de respuesta
      if (responseData['success'] == false) {
        final errorMsg = responseData['message'] as String? ?? 'Error desconocido';
        final errors = responseData['errors'] as Map<String, dynamic>?;
        
        // Extraer mensaje de error más específico si existe
        String? specificError;
        if (errors != null && errors.isNotEmpty) {
          // Intentar obtener el primer error disponible
          final errorValues = errors.values.toList();
          if (errorValues.isNotEmpty) {
            final firstError = errorValues.first;
            if (firstError is String) {
              specificError = firstError;
            } else if (firstError is List && firstError.isNotEmpty) {
              specificError = firstError.first.toString();
            } else if (firstError is Map && firstError.isNotEmpty) {
              specificError = firstError.values.first.toString();
            }
          }
        }
        
            final finalErrorMsg = specificError ?? errorMsg;
            AppLogger.error('API retornó success=false', tag: 'ReservationService', data: {'message': finalErrorMsg, 'errors': errors});
            throw ApiException(finalErrorMsg);
      }
      
          final dataObj = responseData['data'] as Map<String, dynamic>?;

          if (dataObj == null) {
            AppLogger.error('Respuesta sin objeto data', tag: 'ReservationService', data: {'response': responseData});
            throw ApiException('Respuesta inválida: no se encontró el objeto data');
          }

          final reservations = dataObj['reservations'] as List<dynamic>?;

          if (reservations == null) {
            AppLogger.error('No se encontró array reservations en data', tag: 'ReservationService', data: {'data': dataObj});
            throw ApiException('Respuesta inválida: no se encontró el array reservations');
          }
          
          AppLogger.debug('Reservas encontradas: ${reservations.length}', tag: 'ReservationService');

      final pagination = dataObj['pagination'] as Map<String, dynamic>? ?? {};

          // Parsear reservas con manejo de errores individual
          final parsedReservations = <ReservationModel>[];
          
          for (var item in reservations) {
            if (item is! Map<String, dynamic>) {
              AppLogger.warning('Item no es Map', tag: 'ReservationService', data: {'item': item});
              continue;
            }
            try {
              parsedReservations.add(ReservationModel.fromJson(item));
            } catch (e, stackTrace) {
              // Log error pero continuar con las demás reservas
              AppLogger.warning('Error al parsear reserva', tag: 'ReservationService', error: e, stackTrace: stackTrace, data: {'item': item});
            }
          }
          
          AppLogger.info('${parsedReservations.length} reservas parseadas exitosamente', tag: 'ReservationService');

      return PaginatedResponse<ReservationModel>(
        data: parsedReservations,
        currentPage: pagination['current_page'] as int? ?? 1,
        totalPages: pagination['last_page'] as int? ?? 1,
        totalItems: pagination['total'] as int? ?? 0,
        perPage: pagination['per_page'] as int? ?? 15,
      );
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al obtener reservas',
      );
    } catch (e, stackTrace) {
      if (e is ApiException) rethrow;
      AppLogger.error('Error inesperado al obtener reservas', tag: 'ReservationService', error: e, stackTrace: stackTrace);
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtener reserva por ID
  static Future<ReservationModel> getReservation(int id) async {
    try {
      final response = await ApiService.get('/cazador/reservations/$id');
      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al obtener reserva',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Crear nueva reserva
  static Future<ReservationModel> createReservation(
      ReservationModel reservation) async {
    try {
      final response = await ApiService.post(
        '/cazador/reservations',
        data: reservation.toCreateJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al crear reserva',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar reserva (PATCH)
  static Future<ReservationModel> updateReservation(
    int id,
    ReservationModel reservation,
  ) async {
    try {
      final response = await ApiService.patch(
        '/cazador/reservations/$id',
        data: reservation.toUpdateJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al actualizar reserva',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Confirmar reserva con imagen
  static Future<ReservationModel> confirmReservation(
    int id,
    String imagePath, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw ApiException('El archivo de imagen no existe');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        if (additionalData != null) ...additionalData,
      });

      final response = await ApiService.post(
        '/cazador/reservations/$id/confirm',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al confirmar reserva',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Cancelar reserva
  static Future<ReservationModel> cancelReservation(
    int id,
    String cancelNote,
  ) async {
    try {
      if (cancelNote.trim().length < 10) {
        throw ApiException(
            'La nota de cancelación debe tener al menos 10 caracteres');
      }

      final response = await ApiService.post(
        '/cazador/reservations/$id/cancel',
        data: {'cancel_note': cancelNote},
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al cancelar reserva',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Convertir reserva a venta
  static Future<ReservationModel> convertToSale(int id) async {
    try {
      final response = await ApiService.post(
        '/cazador/reservations/$id/convert-to-sale',
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final reservationData =
          dataObj?['reservation'] ?? dataObj ?? responseData;

      return ReservationModel.fromJson(
          reservationData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(
        e,
        defaultMessage: 'Error al convertir reserva a venta',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

