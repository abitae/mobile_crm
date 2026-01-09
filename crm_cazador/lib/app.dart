import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'config/routes.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';

/// Widget principal de la aplicación
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('🔧 Construyendo App widget...');
    }
    try {
      if (kDebugMode) {
        print('🔗 Obteniendo router...');
      }
      final router = ref.watch(routesProvider);
      if (kDebugMode) {
        print('✅ Router obtenido correctamente');
      }

      return MaterialApp.router(
        title: 'LER Cazador',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        // Configuraciones para depuración
        builder: (context, child) {
          // En modo debug, agregar overlay de información
          if (kDebugMode) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          }
          return child ?? const SizedBox.shrink();
        },
      );
    } catch (e, stackTrace) {
      // Si hay un error al construir el router, mostrar un error widget
      if (kDebugMode) {
        print('❌ Error al construir App: $e');
        print('Stack trace: $stackTrace');
      }
      
      return MaterialApp(
        title: 'LER Cazador',
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al inicializar la aplicación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

/// Inicializar servicios de la aplicación
Future<void> initApp() async {
  try {
    // Inicializar almacenamiento primero (crítico)
    if (kDebugMode) {
      print('💾 Inicializando StorageService...');
    }
    await StorageService.init();
    if (kDebugMode) {
      print('✅ StorageService inicializado');
    }
  } catch (e) {
    // Si falla el almacenamiento, la app no puede funcionar
    // Pero intentamos continuar para que el usuario vea el error
    if (kDebugMode) {
      print('❌ Error al inicializar StorageService: $e');
    }
  }
  
  try {
    // Inicializar API service (puede fallar si no hay conexión, pero no crítico para iniciar)
    if (kDebugMode) {
      print('🌐 Inicializando ApiService...');
    }
    await ApiService.init();
    if (kDebugMode) {
      print('✅ ApiService inicializado');
    }
  } catch (e) {
    // Si falla la API, la app puede iniciar pero no podrá hacer requests
    // Esto es aceptable para que el usuario pueda configurar la URL
    if (kDebugMode) {
      print('⚠️ Error al inicializar ApiService: $e');
    }
  }
}

