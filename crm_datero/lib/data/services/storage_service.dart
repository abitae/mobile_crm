import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenamiento seguro y persistente
class StorageService {
  // Configuración específica de plataforma para flutter_secure_storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    // Configuración para Android
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // Configuración para iOS
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    // Configuración para Web (usa localStorage en lugar de secure storage)
    webOptions: WebOptions(
      // En Web, flutter_secure_storage usa localStorage con encriptación
      // No requiere configuración adicional
    ),
    // Configuración para Linux
    lOptions: LinuxOptions(),
    // Configuración para Windows
    wOptions: WindowsOptions(),
    // Configuración para macOS
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static SharedPreferences? _prefs;

  /// Inicializar el servicio
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== Almacenamiento seguro (tokens, credenciales) ==========

  /// Guardar token JWT de forma segura
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  /// Obtener token JWT
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  /// Eliminar token JWT
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  /// Guardar refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Obtener refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Eliminar refresh token
  static Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: 'refresh_token');
  }

  // ========== Almacenamiento general (preferencias) ==========

  /// Guardar string
  static Future<bool> saveString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// Obtener string
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Guardar boolean
  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// Obtener boolean
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Guardar int
  static Future<bool> saveInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// Obtener int
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Eliminar una clave
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// Limpiar todo el almacenamiento
  static Future<void> clear() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }

  /// Verificar si existe una clave
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}

