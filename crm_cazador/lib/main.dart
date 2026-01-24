import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar zona de errores para mejor debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // En modo debug, imprimir errores detallados
    if (kDebugMode) {
      debugPrint('❌ Flutter Error: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    }
  };
  
  // Manejar errores de plataforma
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('❌ Platform Error: $error');
      debugPrint('Stack: $stack');
    }
    return true;
  };
  
  // Inicializar servicios con manejo de errores
  try {
    if (kDebugMode) {
      debugPrint('🚀 Iniciando servicios...');
    }
    await initApp();
    if (kDebugMode) {
      debugPrint('✅ Servicios inicializados correctamente');
    }
  } catch (e, stackTrace) {
    // Si falla la inicialización, intentar continuar de todas formas
    if (kDebugMode) {
      debugPrint('⚠️ Error crítico en inicialización: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  // Ejecutar la app incluso si hubo errores en la inicialización
  if (kDebugMode) {
    debugPrint('📱 Ejecutando aplicación...');
  }
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

