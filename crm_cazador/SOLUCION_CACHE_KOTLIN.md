# Solución para Cachés Corruptos de Kotlin

## Problema

Los cachés incrementales de Kotlin se corrompen frecuentemente, causando errores como:

```
Could not close incremental caches in ...\share_plus\kotlin\compileDebugKotlin\cacheable\caches-jvm\jvm\kotlin
```

## Solución Rápida

### Opción 1: Usar el Script (Recomendado)

Ejecuta el script de limpieza:

```powershell
.\limpiar_cache.ps1
```

### Opción 2: Limpieza Manual

```powershell
# 1. Limpiar Flutter
flutter clean

# 2. Eliminar directorios corruptos
Remove-Item -Path "build\share_plus" -Recurse -Force
Remove-Item -Path "build\shared_preferences_android" -Recurse -Force

# 3. Limpiar Gradle
cd android
.\gradlew.bat clean
cd ..

# 4. Regenerar dependencias
flutter pub get
```

### Opción 3: Limpieza Completa

Si los problemas persisten:

```powershell
# 1. Detener todos los procesos de Java/Gradle
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Limpiar todo
flutter clean
cd android
.\gradlew.bat clean --no-daemon
.\gradlew.bat --stop
cd ..

# 3. Eliminar directorio build completo
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

# 4. Regenerar
flutter pub get
```

## Prevención

Para evitar que esto vuelva a pasar:

1. **Cierra Android Studio** antes de ejecutar `flutter clean`
2. **Detén el daemon de Gradle** con `.\gradlew.bat --stop` si hay problemas
3. **No interrumpas** las compilaciones en proceso
4. **Usa `--no-daemon`** en Gradle si los problemas persisten

## Plugins Problemáticos

Los siguientes plugins suelen tener problemas con cachés corruptos:

- `share_plus`
- `shared_preferences_android`
- `flutter_secure_storage`
- `image_picker_android`
- `path_provider_android`
- `url_launcher_android`

Si un plugin específico causa problemas repetidamente, considera:

1. Actualizar a la última versión
2. Reportar el problema al mantenedor del plugin
3. Usar una alternativa si está disponible

## Verificación

Después de limpiar, verifica que todo esté correcto:

```powershell
flutter doctor
flutter pub get
flutter analyze
```

Si todo está bien, intenta compilar:

```powershell
flutter build apk --debug
```
