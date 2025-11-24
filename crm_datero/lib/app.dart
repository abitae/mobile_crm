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
    final router = ref.watch(routesProvider);

    return MaterialApp.router(
      title: 'LER Datero',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Inicializar servicios de la aplicación
Future<void> initApp() async {
  await StorageService.init();
  await ApiService.init();
}

