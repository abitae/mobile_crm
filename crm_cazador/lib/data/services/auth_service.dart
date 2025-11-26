import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio de autenticación para Cazador
class AuthService {
  /// Login de usuario (prefijo /cazador)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await ApiService.post(
        '/cazador/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      
      if (dataObj == null) {
        throw ApiException('Respuesta inválida del servidor');
      }

      // Extraer token y datos del usuario
      final token = dataObj['token'] as String?;
      final userData = dataObj['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw ApiException('Token o usuario no recibido');
      }

      // Verificar que el usuario sea vendedor (cazador)
      final user = UserModel.fromJson(userData);
      if (user.role?.toLowerCase() != 'vendedor') {
        throw ApiException('Acceso denegado. Solo usuarios con rol vendedor pueden acceder.');
      }

      // Guardar token
      await StorageService.saveToken(token);

      // Guardar refresh token si viene en data
      final refreshToken = dataObj['refresh_token'] as String?;
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }

      // Guardar preferencia de recordarme
      await StorageService.saveBool('remember_me', rememberMe);

      return {
        'user': user,
        'token': token,
      };
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Credenciales inválidas');
      } else if (e.response?.statusCode == 403) {
        throw ApiException(
          errorMessage ?? 'Acceso denegado. Solo usuarios con rol vendedor pueden acceder.',
        );
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
          specificError ?? errorMessage ?? 'Error de validación',
        );
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Too Many Requests');
      }
      throw ApiException(errorMessage ?? 'Error de conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Logout de usuario
  static Future<void> logout() async {
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        try {
          await ApiService.post('/cazador/auth/logout');
        } catch (e) {
          // Continuar con logout local aunque falle el servidor
        }
      }
    } finally {
      await StorageService.deleteToken();
      await StorageService.deleteRefreshToken();
      await StorageService.remove('remember_me');
    }
  }

  /// Obtener usuario autenticado
  static Future<UserModel?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/cazador/auth/me');
      final responseData = response.data as Map<String, dynamic>;
      final userData = responseData['data'] ?? responseData;

      return UserModel.fromJson(userData as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data;
        String? errorMessage;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String?;
        }
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      }
      return null;
    } catch (e) {
      if (e is ApiException) rethrow;
      return null;
    }
  }

  /// Verificar si hay una sesión activa
  static Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    return token != null;
  }

  /// Refresh token
  static Future<String?> refreshToken() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final response = await ApiService.post('/cazador/auth/refresh');

      final responseData = response.data as Map<String, dynamic>;
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      final newToken = dataObj?['token'] as String? ?? responseData['token'] as String?;

      if (newToken != null) {
        await StorageService.saveToken(newToken);
        return newToken;
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data;
        String? errorMessage;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String?;
        }
        throw ApiException(errorMessage ?? 'Token inválido o expirado');
      }
      return null;
    } catch (e) {
      if (e is ApiException) rethrow;
      return null;
    }
  }

  /// Cambiar contraseña del usuario
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await ApiService.post(
        '/cazador/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? errorMessage;
      
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
        
        // Si hay errores de validación, extraer el primer error
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstErrorList = errors.values.first;
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            }
          }
        }
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Usuario no autenticado');
      } else if (e.response?.statusCode == 422) {
        throw ApiException(errorMessage ?? 'Error de validación');
      } else if (e.response?.statusCode == 500) {
        throw ApiException(errorMessage ?? 'Error al cambiar la contraseña');
      }
      throw ApiException(errorMessage ?? 'Error de conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

