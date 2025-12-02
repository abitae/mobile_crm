import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Servicio de autenticación
class AuthService {
  /// Registro de datero
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String dni,
    required String pin,
    required int liderId,
    String? banco,
    String? cuentaBancaria,
    String? cciBancaria,
  }) async {
    try {
      final response = await ApiService.post(
        '/datero/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'dni': dni,
          'pin': pin,
          'lider_id': liderId,
          if (banco != null) 'banco': banco,
          if (cuentaBancaria != null) 'cuenta_bancaria': cuentaBancaria,
          if (cciBancaria != null) 'cci_bancaria': cciBancaria,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      
      final dataObj = responseData['data'] as Map<String, dynamic>?;
      
      if (dataObj == null) {
        throw ApiException('Respuesta inválida del servidor');
      }

      final token = dataObj['token'] as String?;
      final userData = dataObj['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw ApiException('Token o usuario no recibido');
      }

      final user = UserModel.fromJson(userData);
      if (!user.isDatero) {
        throw ApiException('Acceso denegado. Solo usuarios datero pueden acceder.');
      }

      await StorageService.saveToken(token);

      final refreshToken = dataObj['refresh_token'] as String?;
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }

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

      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final specificError = errors?.values.first?.first.toString();
        throw ApiException(
          specificError ?? errorMessage ?? 'Error de validación',
        );
      } else if (e.response?.statusCode == 409) {
        throw ApiException(errorMessage ?? 'El DNI o email ya está registrado');
      } else if (e.response?.statusCode == 429) {
        throw ApiException(errorMessage ?? 'Too Many Requests');
      }
      throw ApiException(errorMessage ?? 'Error de conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Login de usuario con DNI y PIN
  static Future<Map<String, dynamic>> login({
    required String dni,
    required String pin,
    bool rememberMe = false,
  }) async {
    try {
      final response = await ApiService.post(
        '/datero/auth/login',
        data: {
          'dni': dni,
          'pin': pin,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Según documentación: { "success": true, "data": { "token": "...", "user": {...} } }
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

      // Verificar que el usuario sea datero
      final user = UserModel.fromJson(userData);
      if (!user.isDatero) {
        throw ApiException('Acceso denegado. Solo usuarios datero pueden acceder.');
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
      // Extraer mensaje de error de la respuesta si está disponible
      final responseData = e.response?.data;
      String? errorMessage;
      
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] as String?;
      }

      if (e.response?.statusCode == 401) {
        throw ApiException(errorMessage ?? 'Credenciales inválidas');
      } else if (e.response?.statusCode == 403) {
        // Puede ser: "Acceso denegado. Solo usuarios con rol datero pueden acceder."
        // o "Tu cuenta está desactivada. Contacta al administrador."
        throw ApiException(
          errorMessage ?? 'Acceso denegado. Solo usuarios con rol datero pueden acceder.',
        );
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        // Priorizar mensaje de error específico del campo, luego mensaje general
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
        // Intentar invalidar token en el servidor
        try {
          await ApiService.post('/datero/auth/logout');
        } catch (e) {
          // Continuar con logout local aunque falle el servidor
        }
      }
    } finally {
      // Limpiar almacenamiento local
      await StorageService.deleteToken();
      await StorageService.deleteRefreshToken();
      await StorageService.remove('remember_me');
    }
  }

  /// Obtener usuario autenticado
  static Future<UserModel?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/datero/auth/me');
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
  /// Según documentación API: usa el Bearer token actual en el header
  static Future<String?> refreshToken() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      // El token se agrega automáticamente por ApiService en el interceptor
      // Según documentación: POST /auth/refresh con Bearer token en header
      final response = await ApiService.post('/datero/auth/refresh');

      final responseData = response.data as Map<String, dynamic>;
      // Según documentación: { "success": true, "data": { "token": "...", "token_type": "bearer", "expires_in": 3600 } }
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

  /// Cambiar PIN del usuario
  static Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    try {
      await ApiService.post(
        '/datero/auth/change-pin',
        data: {
          'current_pin': currentPin,
          'new_pin': newPin,
          'new_pin_confirmation': newPinConfirmation,
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

