import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/exception_helper.dart';
import '../../core/logging/app_logger.dart';

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
      throw ExceptionHelper.fromDioException(e, defaultMessage: 'Error de conexión. Verifica tu internet.');
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

      await StorageService.saveBool('remember_me', rememberMe);
      AppLogger.info('Login exitoso', tag: 'AuthService', data: {'user_id': user.id});

      return {
        'user': user,
        'token': token,
      };
    } on DioException catch (e) {
      AppLogger.apiError('POST', '/datero/auth/login', e, statusCode: e.response?.statusCode);
      throw ExceptionHelper.fromDioException(e, defaultMessage: 'Error de conexión. Verifica tu internet.');
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
      if (e.response?.statusCode == 401) throw ExceptionHelper.fromDioException(e, defaultMessage: 'Usuario no autenticado');
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
      if (e.response?.statusCode == 401) throw ExceptionHelper.fromDioException(e, defaultMessage: 'Token inválido o expirado');
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
      throw ExceptionHelper.fromDioException(e, defaultMessage: 'Error al cambiar PIN');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}

