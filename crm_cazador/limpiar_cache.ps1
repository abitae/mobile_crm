# Script para limpiar cachés corruptos de Kotlin
Write-Host "Limpiando cachés de Flutter y Kotlin..." -ForegroundColor Yellow

# Limpiar Flutter
Write-Host "`n1. Limpiando Flutter..." -ForegroundColor Cyan
flutter clean

# Eliminar directorios específicos de plugins problemáticos
Write-Host "`n2. Eliminando cachés corruptos de plugins..." -ForegroundColor Cyan

$directorios = @(
    "build\share_plus",
    "build\shared_preferences_android",
    "build\flutter_secure_storage",
    "build\image_picker_android",
    "build\path_provider_android",
    "build\url_launcher_android"
)

foreach ($dir in $directorios) {
    $path = Join-Path $PSScriptRoot $dir
    if (Test-Path $path) {
        Write-Host "  Eliminando: $dir" -ForegroundColor Gray
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Limpiar Gradle
Write-Host "`n3. Limpiando Gradle..." -ForegroundColor Cyan
if (Test-Path "android\gradlew.bat") {
    Set-Location android
    .\gradlew.bat clean --no-daemon
    Set-Location ..
} else {
    Write-Host "  gradlew.bat no encontrado, saltando limpieza de Gradle" -ForegroundColor Yellow
}

# Regenerar dependencias
Write-Host "`n4. Regenerando dependencias..." -ForegroundColor Cyan
flutter pub get

Write-Host "`n✓ Limpieza completada!" -ForegroundColor Green
Write-Host "`nAhora puedes ejecutar: flutter run" -ForegroundColor Yellow
