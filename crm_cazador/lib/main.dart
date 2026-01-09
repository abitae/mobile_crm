import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios con manejo de errores
  try {
    print('Iniciando servicios...');
    await initApp();
    print('Servicios inicializados correctamente');
  } catch (e, stackTrace) {
    // Si falla la inicialización, intentar continuar de todas formas
    // para que el usuario pueda ver el error o configurar la app
    print('⚠️ Error crítico en inicialización: $e');
    print('Stack trace: $stackTrace');
  }
  
  // Ejecutar la app incluso si hubo errores en la inicialización
  print('Ejecutando aplicación...');
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

