/// Configuración global de la aplicación
class AppConfig {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // URLs por defecto según entorno
  static const String defaultProductionUrl =
      'https://crm.lotesenremate.pe/api';
  static const String defaultStagingUrl =
      'https://crm-stag.lotesenremate.pe/api';
  static const String defaultDevelopmentUrl =
      'https://crm-dev.lotesenremate.pe/api';

  // URL por defecto (puede ser sobreescrita por configuración del usuario)
  static String get defaultBaseUrl => defaultProductionUrl;

  // Nombres de keys para almacenamiento
  static const String keyRememberMe = 'remember_me';
  static const String keyUserId = 'user_id';
}

