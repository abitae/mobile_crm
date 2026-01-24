import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../../core/logging/app_logger.dart';

/// Servicio de caché persistente usando Hive
class HiveCacheService {
  static const String _clientsBoxName = 'clients_cache';
  static const String _daterosBoxName = 'dateros_cache';
  static const String _projectsBoxName = 'projects_cache';
  static const String _reservationsBoxName = 'reservations_cache';
  static const String _cacheTimestampKey = '_cache_timestamp';
  static const String _cacheExpiryKey = '_cache_expiry';
  
  // Duración de caché por defecto (24 horas)
  static const Duration defaultCacheDuration = Duration(hours: 24);
  
  static bool _initialized = false;

  /// Inicializar Hive y abrir boxes
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      await Hive.initFlutter();
      await _openBoxes();
      _initialized = true;
      AppLogger.info('Hive cache inicializado', tag: 'HiveCache');
    } catch (e, stackTrace) {
      AppLogger.error('Error al inicializar Hive cache', tag: 'HiveCache', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Abrir todos los boxes necesarios
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox(_clientsBoxName),
      Hive.openBox(_daterosBoxName),
      Hive.openBox(_projectsBoxName),
      Hive.openBox(_reservationsBoxName),
    ]);
  }

  /// Obtener box por nombre
  static Box _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName no está abierto');
    }
    return Hive.box(boxName);
  }

  /// Guardar lista de items en caché
  static Future<void> putList<T>(
    String boxName,
    String key,
    List<T> items, {
    Duration? expiry,
  }) async {
    try {
      final box = _getBox(boxName);
      final expiryDuration = expiry ?? defaultCacheDuration;
      final expiryTime = DateTime.now().add(expiryDuration);
      
      final cacheData = {
        'items': items.map((item) => _serializeItem(item)).toList(),
        _cacheTimestampKey: DateTime.now().toIso8601String(),
        _cacheExpiryKey: expiryTime.toIso8601String(),
      };
      
      await box.put(key, jsonEncode(cacheData));
      AppLogger.cachePut('$boxName/$key');
    } catch (e, stackTrace) {
      AppLogger.error('Error al guardar en caché', tag: 'HiveCache', error: e, stackTrace: stackTrace);
    }
  }

  /// Obtener lista de items del caché
  static List<T>? getList<T>(
    String boxName,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final box = _getBox(boxName);
      final cachedData = box.get(key);
      
      if (cachedData == null) {
        AppLogger.cacheMiss('$boxName/$key');
        return null;
      }
      
      final data = jsonDecode(cachedData as String) as Map<String, dynamic>;
      
      // Verificar expiración
      final expiryStr = data[_cacheExpiryKey] as String?;
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          AppLogger.cacheMiss('$boxName/$key (expired)');
          box.delete(key);
          return null;
        }
      }
      
      final items = (data['items'] as List<dynamic>?)
          ?.map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
      
      AppLogger.cacheHit('$boxName/$key');
      return items;
    } catch (e, stackTrace) {
      AppLogger.error('Error al leer del caché', tag: 'HiveCache', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Serializar item a JSON
  static Map<String, dynamic> _serializeItem<T>(T item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    // Si el item tiene método toJson, usarlo
    try {
      return (item as dynamic).toJson() as Map<String, dynamic>;
    } catch (e) {
      // Si no tiene toJson, intentar convertir a string y luego a JSON
      return {'data': item.toString()};
    }
  }

  /// Invalidar caché de una key específica
  static Future<void> invalidate(String boxName, String key) async {
    try {
      final box = _getBox(boxName);
      await box.delete(key);
      AppLogger.cacheInvalidate('$boxName/$key');
    } catch (e, stackTrace) {
      AppLogger.error('Error al invalidar caché', tag: 'HiveCache', error: e, stackTrace: stackTrace);
    }
  }

  /// Limpiar todo el caché de un box
  static Future<void> clearBox(String boxName) async {
    try {
      final box = _getBox(boxName);
      await box.clear();
      AppLogger.info('Caché limpiado: $boxName', tag: 'HiveCache');
    } catch (e, stackTrace) {
      AppLogger.error('Error al limpiar caché', tag: 'HiveCache', error: e, stackTrace: stackTrace);
    }
  }

  /// Limpiar todo el caché
  static Future<void> clearAll() async {
    try {
      await Future.wait([
        clearBox(_clientsBoxName),
        clearBox(_daterosBoxName),
        clearBox(_projectsBoxName),
        clearBox(_reservationsBoxName),
      ]);
      AppLogger.info('Todo el caché limpiado', tag: 'HiveCache');
    } catch (e, stackTrace) {
      AppLogger.error('Error al limpiar todo el caché', tag: 'HiveCache', error: e, stackTrace: stackTrace);
    }
  }

  /// Métodos específicos para cada tipo de dato

  /// Guardar clientes en caché
  static Future<void> putClients(String key, List<dynamic> clients, {Duration? expiry}) {
    return putList(_clientsBoxName, key, clients, expiry: expiry);
  }

  /// Obtener clientes del caché
  static List<T>? getClients<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    return getList<T>(_clientsBoxName, key, fromJson);
  }

  /// Guardar dateros en caché
  static Future<void> putDateros(String key, List<dynamic> dateros, {Duration? expiry}) {
    return putList(_daterosBoxName, key, dateros, expiry: expiry);
  }

  /// Obtener dateros del caché
  static List<T>? getDateros<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    return getList<T>(_daterosBoxName, key, fromJson);
  }

  /// Guardar proyectos en caché
  static Future<void> putProjects(String key, List<dynamic> projects, {Duration? expiry}) {
    return putList(_projectsBoxName, key, projects, expiry: expiry);
  }

  /// Obtener proyectos del caché
  static List<T>? getProjects<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    return getList<T>(_projectsBoxName, key, fromJson);
  }

  /// Guardar reservas en caché
  static Future<void> putReservations(String key, List<dynamic> reservations, {Duration? expiry}) {
    return putList(_reservationsBoxName, key, reservations, expiry: expiry);
  }

  /// Obtener reservas del caché
  static List<T>? getReservations<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    return getList<T>(_reservationsBoxName, key, fromJson);
  }

  /// Generar key de caché basada en parámetros
  static String generateCacheKey(String base, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return base;
    }
    
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    final paramsStr = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '$base?$paramsStr';
  }
}
