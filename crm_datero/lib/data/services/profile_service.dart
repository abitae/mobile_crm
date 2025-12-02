import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio para gestión de perfil
class ProfileService {
  /// Obtener perfil del usuario autenticado
  static Future<UserModel> getProfile() async {
    try {
      final response = await ApiService.get('/datero/profile');
      final responseData = response.data as Map<String, dynamic>;
      // Según documentación: { "success": true, "data": {...} }
      final userData = responseData['data'] ?? responseData;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(errorMessage ?? 'Error al obtener perfil: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar perfil del usuario autenticado
  static Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? banco,
    String? cuentaBancaria,
    String? cciBancaria,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (banco != null) data['banco'] = banco;
      if (cuentaBancaria != null) data['cuenta_bancaria'] = cuentaBancaria;
      if (cciBancaria != null) data['cci_bancaria'] = cciBancaria;

      final response = await ApiService.put(
        '/datero/profile',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      // Según documentación: { "success": true, "data": {...} }
      final userData = responseData['data'] ?? responseData;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(specificError ?? errorMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      throw ApiException(errorMessage ?? 'Error al actualizar perfil: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

