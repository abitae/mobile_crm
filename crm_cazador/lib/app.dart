import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'config/routes.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';
import 'presentation/widgets/connectivity/connectivity_banner.dart';
import 'data/cache/hive_cache_service.dart';

/// Widget principal de la aplicación
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('🔧 Construyendo App widget...');
    }
    try {
      if (kDebugMode) {
        debugPrint('🔗 Obteniendo router...');
      }
      final router = ref.watch(routesProvider);
      if (kDebugMode) {
        debugPrint('✅ Router obtenido correctamente');
      }

      return MaterialApp.router(
        title: 'LER Cazador',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        // Configuraciones para depuración
        builder: (context, child) {
          Widget result = child ?? const SizedBox.shrink();
          
          // Agregar banner de conectividad
          result = Column(
            children: [
              const ConnectivityBanner(),
              Expanded(child: result),
            ],
          );
          
          // En modo debug, agregar overlay de información
          if (kDebugMode) {
            result = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
              ),
              child: result,
            );
          }
          return result;
        },
      );
    } catch (e, stackTrace) {
      // Si hay un error al construir el router, mostrar un error widget
      if (kDebugMode) {
        debugPrint('❌ Error al construir App: $e');
        debugPrint('Stack trace: $stackTrace');
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
      debugPrint('💾 Inicializando StorageService...');
    }
    await StorageService.init();
    if (kDebugMode) {
      debugPrint('✅ StorageService inicializado');
    }

    // Inicializar caché Hive
    if (kDebugMode) {
      debugPrint('💾 Inicializando HiveCacheService...');
    }
    try {
      await HiveCacheService.init();
      if (kDebugMode) {
        debugPrint('✅ HiveCacheService inicializado');
      }
    } catch (e) {
      // Si falla el caché, continuar sin él
      if (kDebugMode) {
        debugPrint('⚠️ Error al inicializar HiveCacheService: $e');
      }
    }
  } catch (e) {
    // Si falla el almacenamiento, la app no puede funcionar
    // Pero intentamos continuar para que el usuario vea el error
    if (kDebugMode) {
      debugPrint('❌ Error al inicializar StorageService: $e');
    }
  }
  
  try {
    // Inicializar API service (puede fallar si no hay conexión, pero no crítico para iniciar)
    if (kDebugMode) {
      debugPrint('🌐 Inicializando ApiService...');
    }
    await ApiService.init();
    if (kDebugMode) {
      debugPrint('✅ ApiService inicializado');
    }
  } catch (e) {
    // Si falla la API, la app puede iniciar pero no podrá hacer requests
    // Esto es aceptable para que el usuario pueda configurar la URL
    if (kDebugMode) {
      debugPrint('⚠️ Error al inicializar ApiService: $e');
    }
  }
}

