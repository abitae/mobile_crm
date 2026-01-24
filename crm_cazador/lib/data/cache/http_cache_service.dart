import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar caché HTTP usando ETag, Last-Modified y Cache-Control
class HttpCacheService {
  static const String _etagPrefix = 'http_cache_etag_';
  static const String _lastModifiedPrefix = 'http_cache_last_modified_';
  static const String _cacheControlPrefix = 'http_cache_control_';

  /// Obtener ETag almacenado para una URL
  static Future<String?> getETag(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_etagPrefix$url');
    } catch (e) {
      return null;
    }
  }

  /// Guardar ETag para una URL
  static Future<void> setETag(String url, String etag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_etagPrefix$url', etag);
    } catch (e) {
      // Ignorar errores de almacenamiento
    }
  }

  /// Obtener Last-Modified almacenado para una URL
  static Future<String?> getLastModified(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_lastModifiedPrefix$url');
    } catch (e) {
      return null;
    }
  }

  /// Guardar Last-Modified para una URL
  static Future<void> setLastModified(String url, String lastModified) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_lastModifiedPrefix$url', lastModified);
    } catch (e) {
      // Ignorar errores de almacenamiento
    }
  }

  /// Obtener Cache-Control almacenado para una URL
  static Future<String?> getCacheControl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cacheControlPrefix$url');
    } catch (e) {
      return null;
    }
  }

  /// Guardar Cache-Control para una URL
  static Future<void> setCacheControl(String url, String cacheControl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cacheControlPrefix$url', cacheControl);
    } catch (e) {
      // Ignorar errores de almacenamiento
    }
  }

  /// Verificar si una respuesta está en caché y es válida
  static Future<bool> isCachedAndValid(String url, Response response) async {
    final cacheControl = response.headers.value('cache-control');
    if (cacheControl != null) {
      await setCacheControl(url, cacheControl);
      
      // Si tiene no-cache o no-store, no usar caché
      if (cacheControl.contains('no-cache') || cacheControl.contains('no-store')) {
        return false;
      }
      
      // Extraer max-age si existe
      final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
      if (maxAgeMatch != null) {
        final maxAge = int.tryParse(maxAgeMatch.group(1) ?? '0') ?? 0;
        if (maxAge > 0) {
          // Verificar si el caché expiró (esto se manejaría con timestamps)
          // Por ahora, confiamos en ETag y Last-Modified
        }
      }
    }

    // Guardar ETag y Last-Modified si existen
    final etag = response.headers.value('etag');
    if (etag != null) {
      await setETag(url, etag);
    }

    final lastModified = response.headers.value('last-modified');
    if (lastModified != null) {
      await setLastModified(url, lastModified);
    }

    return true;
  }

  /// Agregar headers de validación condicional a una request
  static Future<void> addConditionalHeaders(
    RequestOptions options,
  ) async {
    final url = options.uri.toString();
    
    // Agregar If-None-Match si tenemos ETag
    final etag = await getETag(url);
    if (etag != null) {
      options.headers['If-None-Match'] = etag;
    }

    // Agregar If-Modified-Since si tenemos Last-Modified
    final lastModified = await getLastModified(url);
    if (lastModified != null) {
      options.headers['If-Modified-Since'] = lastModified;
    }
  }

  /// Limpiar caché para una URL específica
  static Future<void> clearCache(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_etagPrefix$url');
      await prefs.remove('$_lastModifiedPrefix$url');
      await prefs.remove('$_cacheControlPrefix$url');
    } catch (e) {
      // Ignorar errores
    }
  }

  /// Limpiar todo el caché HTTP
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_etagPrefix) ||
            key.startsWith(_lastModifiedPrefix) ||
            key.startsWith(_cacheControlPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Ignorar errores
    }
  }
}
