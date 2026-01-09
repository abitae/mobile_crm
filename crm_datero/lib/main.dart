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
      print('❌ Flutter Error: ${details.exception}');
      print('Stack: ${details.stack}');
    }
  };
  
  // Manejar errores de plataforma
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('❌ Platform Error: $error');
      print('Stack: $stack');
    }
    return true;
  };
  
  // Inicializar servicios con manejo de errores
  try {
    if (kDebugMode) {
      print('🚀 Iniciando servicios...');
    }
    await initApp();
    if (kDebugMode) {
      print('✅ Servicios inicializados correctamente');
    }
  } catch (e, stackTrace) {
    // Si falla la inicialización, intentar continuar de todas formas
    if (kDebugMode) {
      print('⚠️ Error crítico en inicialización: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  // Ejecutar la app incluso si hubo errores en la inicialización
  if (kDebugMode) {
    print('📱 Ejecutando aplicación...');
  }
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
