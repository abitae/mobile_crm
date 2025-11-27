import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../config/api_config.dart';
import 'storage_service.dart';
import 'auth_service.dart';

/// Servicio base para comunicación con la API
class ApiService {
  static Dio? _dio;
  static bool _initialized = false;

  /// Inicializar el servicio de API
  static Future<void> init() async {
    if (_initialized) return;

    final baseUrl = await ApiConfigService.getBaseUrl();
    final normalizedUrl = ApiConfigService.normalizeUrl(baseUrl);

    _dio = Dio(BaseOptions(
      baseUrl: normalizedUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Optimizaciones de rendimiento
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500, // Aceptar códigos < 500
      // Comprimir respuestas si el servidor lo soporta
      listFormat: ListFormat.multiCompatible,
    ));

    // Interceptor para agregar token automáticamente
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Manejar 401 (token expirado o inválido) - intentar refresh token
        if (error.response?.statusCode == 401) {
          // Evitar loops infinitos: solo intentar refresh si no es una petición de refresh
          final requestPath = error.requestOptions.path;
          if (!requestPath.contains('/auth/refresh') && 
              !requestPath.contains('/auth/login')) {
            try {
              final newToken = await AuthService.refreshToken();
              if (newToken != null) {
                // Reintentar la petición original con el nuevo token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                
                try {
                  final response = await _dio!.fetch(opts);
                  return handler.resolve(response);
                } catch (e) {
                  // Si el reintento falla, el token es inválido
                  // Limpiar tokens y dejar que el error se propague
                  await StorageService.deleteToken();
                  await StorageService.deleteRefreshToken();
                }
              } else {
                // Si no hay nuevo token, limpiar tokens almacenados
                await StorageService.deleteToken();
                await StorageService.deleteRefreshToken();
              }
            } catch (e) {
              // Si el refresh falla completamente, limpiar tokens
              await StorageService.deleteToken();
              await StorageService.deleteRefreshToken();
            }
          }
        }
        return handler.next(error);
      },
    ));

    // Interceptor para logging solo en modo debug
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: false, // Desactivar en producción para mejor rendimiento
        responseBody: false, // Desactivar en producción para mejor rendimiento
        error: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) {
          // Solo loggear errores en producción
          if (obj.toString().contains('ERROR') || obj.toString().contains('Exception')) {
            print(obj);
          }
        },
      ));
    }

    _initialized = true;
  }

  /// Obtener instancia de Dio
  static Dio get dio {
    if (_dio == null) {
      throw Exception('ApiService no ha sido inicializado. Llama a init() primero.');
    }
    return _dio!;
  }

  /// Actualizar base URL
  static Future<void> updateBaseUrl(String url) async {
    final normalizedUrl = ApiConfigService.normalizeUrl(url);
    _dio?.options.baseUrl = normalizedUrl;
  }

  /// GET request
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await init();
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await init();
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await init();
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  static Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await init();
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await init();
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

