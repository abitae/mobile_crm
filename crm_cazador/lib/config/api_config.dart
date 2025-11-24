import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

enum ApiEnvironment {
  production('Producción', AppConfig.defaultProductionUrl),
  staging('Staging', AppConfig.defaultStagingUrl),
  development('Desarrollo', AppConfig.defaultDevelopmentUrl),
  custom('Personalizada', '');

  final String label;
  final String defaultUrl;

  const ApiEnvironment(this.label, this.defaultUrl);
}

class ApiConfigService {
  static const String _envKey = 'api_environment';
  static const String _customUrlKey = 'api_custom_url';

  // Obtener URL base configurada
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final envString =
        prefs.getString(_envKey) ?? ApiEnvironment.production.name;
    final environment = ApiEnvironment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => ApiEnvironment.production,
    );

    if (environment == ApiEnvironment.custom) {
      final customUrl = prefs.getString(_customUrlKey);
      if (customUrl != null && customUrl.isNotEmpty) {
        return customUrl;
      }
      return AppConfig.defaultProductionUrl;
    }

    return environment.defaultUrl;
  }

  // Guardar configuración de entorno
  static Future<void> setEnvironment(ApiEnvironment environment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_envKey, environment.name);
  }

  // Guardar URL personalizada
  static Future<void> setCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customUrlKey, url);
  }

  // Obtener entorno actual
  static Future<ApiEnvironment> getCurrentEnvironment() async {
    final prefs = await SharedPreferences.getInstance();
    final envString =
        prefs.getString(_envKey) ?? ApiEnvironment.production.name;
    return ApiEnvironment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => ApiEnvironment.production,
    );
  }

  // Validar formato de URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Normalizar URL (agregar /api si no está presente)
  static String normalizeUrl(String url) {
    if (!url.endsWith('/api') && !url.endsWith('/api/')) {
      return url.endsWith('/') ? '${url}api' : '$url/api';
    }
    return url;
  }

  // Resetear a configuración por defecto
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_envKey);
    await prefs.remove(_customUrlKey);
  }

  // Test de conectividad con el servidor
  static Future<bool> testConnection(String url) async {
    try {
      // TODO: Implementar test de conexión real con Dio
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener URL base sin /api para recursos estáticos (imágenes, videos, documentos)
  static Future<String> getResourceBaseUrl() async {
    final baseUrl = await getBaseUrl();
    // Remover /api del final si está presente
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    } else if (baseUrl.endsWith('/api/')) {
      return baseUrl.substring(0, baseUrl.length - 5);
    }
    return baseUrl;
  }

  // Construir URL completa para un recurso (imagen, video, documento)
  static Future<String> buildResourceUrl(String? path) async {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    // Si ya es una URL completa, retornarla tal cual
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Si es una ruta relativa, construir la URL completa
    final resourceBaseUrl = await getResourceBaseUrl();
    final normalizedBase = resourceBaseUrl.endsWith('/') 
        ? resourceBaseUrl.substring(0, resourceBaseUrl.length - 1)
        : resourceBaseUrl;
    
    // Asegurar que el path comience con /
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    
    return '$normalizedBase$normalizedPath';
  }
}

