# Diagnóstico de Problemas de Inicialización

## Pasos para Diagnosticar

### 1. Verificar Logs en la Consola

Ejecuta la aplicación y revisa los logs en la consola. Deberías ver:

```
Iniciando servicios...
Servicios inicializados correctamente
Ejecutando aplicación...
Construyendo App widget...
Obteniendo router...
Router obtenido correctamente
```

Si ves algún error antes de estos mensajes, ese es el problema.

### 2. Errores Comunes

#### Error: "StorageService no inicializado"
- **Causa**: `SharedPreferences` no se puede inicializar
- **Solución**: Verificar permisos de almacenamiento en Android/iOS

#### Error: "ApiService no inicializado"
- **Causa**: Error al leer configuración de API
- **Solución**: Verificar que `SharedPreferences` esté funcionando

#### Error: "AuthNotifier error"
- **Causa**: Error al verificar autenticación
- **Solución**: La app debería continuar y mostrar login

#### Error: "Router error"
- **Causa**: Error al crear GoRouter
- **Solución**: Verificar que todas las rutas estén correctamente definidas

### 3. Verificar Archivos Críticos

1. **main.dart**: Debe tener `WidgetsFlutterBinding.ensureInitialized()`
2. **app.dart**: Debe tener manejo de errores en `build()`
3. **routes.dart**: El `routesProvider` debe manejar errores
4. **auth_provider.dart**: `_checkAuth()` debe manejar errores

### 4. Probar en Modo Debug

Ejecuta con:
```bash
flutter run --verbose
```

Esto mostrará más información sobre qué está fallando.

### 5. Verificar Dependencias

Asegúrate de que todas las dependencias estén instaladas:
```bash
flutter pub get
```

### 6. Limpiar y Reconstruir

Si persisten los problemas:
```bash
flutter clean
flutter pub get
flutter run
```

## Cambios Realizados para Mejorar la Inicialización

1. ✅ Manejo de errores en `main()`
2. ✅ Manejo de errores en `initApp()`
3. ✅ Fallback en `ApiService.init()`
4. ✅ Manejo de errores en `AuthProvider._checkAuth()`
5. ✅ Timeout en `SplashScreen`
6. ✅ Manejo de errores en `routesProvider`
7. ✅ Widget de error en `App.build()`
8. ✅ Logging detallado para diagnóstico

## Próximos Pasos

Si la app aún no se inicializa:

1. **Revisa los logs** en la consola para identificar el error exacto
2. **Comparte los logs** para análisis más detallado
3. **Verifica** que no haya problemas de red o permisos
4. **Prueba** en un dispositivo/emulador diferente
