import 'package:dio/dio.dart';
import 'dart:io';
import 'api_service.dart';
import '../models/reservation_model.dart';
import '../models/api_response.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de reservas (Cazador)
class ReservationService {
  /// Obtener lista de reservas paginada
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

      final response = await ApiService.get(
        '/cazador/reservations',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;

      if (dataObj == null) {
        throw ApiException('Respuesta inválida: no se encontró el objeto data');
      }

      final reservations = dataObj['reservations'] as List<dynamic>?;

      if (reservations == null) {
        throw ApiException('Respuesta inválida: no se encontró el array reservations');
      }

      final pagination = dataObj['pagination'] as Map<String, dynamic>? ?? {};

      final parsedReservations = reservations
          .whereType<Map<String, dynamic>>()
          .map((item) => ReservationModel.fromJson(item))
          .toList();

      return PaginatedResponse<ReservationModel>(
        data: parsedReservations,
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

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Too Many Requests');
      }
      throw ApiException(
          errorMessage ?? 'Error al obtener reservas: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
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
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(errorMessage ?? 'Reserva no encontrada');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            errorMessage ?? 'No tienes permiso para acceder a esta reserva');
      }
      throw ApiException(
          errorMessage ?? 'Error al obtener reserva: ${e.message}');
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
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
            specificError ?? apiMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(
            apiMessage ?? 'Cliente, proyecto o unidad no encontrados');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(apiMessage ?? 'Too Many Requests');
      }
      throw ApiException(apiMessage ?? 'Error al crear reserva: ${e.message}');
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
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Reserva no encontrada');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            apiMessage ?? 'No tienes permiso para actualizar esta reserva');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
            specificError ??
                apiMessage ??
                'Solo se pueden editar reservas activas o error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(
          apiMessage ?? 'Error al actualizar reserva: ${e.message}');
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
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 400) {
        throw ApiException(apiMessage ?? 'ID de reserva inválido');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            apiMessage ?? 'No tienes permiso para confirmar esta reserva');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Reserva no encontrada');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
            specificError ??
                apiMessage ??
                'Solo se pueden confirmar reservas activas o error de validación');
      }
      throw ApiException(
          apiMessage ?? 'Error al confirmar reserva: ${e.message}');
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
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 400) {
        throw ApiException(apiMessage ?? 'ID de reserva inválido');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            apiMessage ?? 'No tienes permiso para cancelar esta reserva');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Reserva no encontrada');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
            specificError ??
                apiMessage ??
                'La reserva no puede ser cancelada o error de validación');
      }
      throw ApiException(
          apiMessage ?? 'Error al cancelar reserva: ${e.message}');
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
      final responseData = e.response?.data;
      String? apiMessage;
      if (responseData is Map<String, dynamic>) {
        apiMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 400) {
        throw ApiException(apiMessage ?? 'ID de reserva inválido');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(apiMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
            apiMessage ?? 'No tienes permiso para convertir esta reserva');
      } else if (e.response?.statusCode == 404) {
        throw ApiException(apiMessage ?? 'Reserva no encontrada');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
            specificError ??
                apiMessage ??
                'Solo se pueden convertir reservas confirmadas o unidad no puede venderse');
      }
      throw ApiException(
          apiMessage ?? 'Error al convertir reserva a venta: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

