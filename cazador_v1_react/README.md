# cazador_v1_react (Veridian)

App CRM inmobiliario en React Native con Expo. Usa **Development Build** (no Expo Go).

## Requisitos

- Node.js 18+
- npm o yarn
- Android: Android Studio y SDK / emulador o dispositivo
- iOS (solo macOS): Xcode y simulador o dispositivo
- Para builds en la nube: cuenta en [expo.dev](https://expo.dev) y [EAS CLI](https://docs.expo.dev/build/setup/)

### Variable ANDROID_HOME

Si el SDK de Android no está en `C:\Users\<tu_usuario>\AppData\Local\Android\Sdk`, define la variable de entorno. En PowerShell (solo esta ventana):

```powershell
$env:ANDROID_HOME = "E:\Android"   # usa la ruta donde tengas el SDK
```

Para dejarlo fijo en Windows: **Configuración → Sistema → Acerca de → Configuración avanzada del sistema → Variables de entorno**. Crea o edita `ANDROID_HOME` y pon la ruta del SDK (por ejemplo `E:\Android`).

### Java 17 o 21 para el build Android

Gradle no soporta Java 25. Si ves **"Unsupported class file major version 69"**, usa JDK 17 o 21. En PowerShell (solo esta ventana):

```powershell
# Ruta típica si usas Android Studio (JDK embebido) o un JDK instalado:
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"   # JBR 17 de Android Studio
# o, si tienes JDK 21 instalado por separado:
# $env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
```

Luego vuelve a ejecutar `npm run android`. Para dejarlo fijo, añade `JAVA_HOME` en las variables de entorno de Windows (igual que `ANDROID_HOME`).

## Instalación

```bash
npm install
```

## Desarrollo con Development Build

### 1. Generar código nativo (prebuild)

La primera vez o al cambiar dependencias nativas:

```bash
npm run prebuild
```

Esto crea las carpetas `android/` e `ios/` (no se versionan; EAS Build las genera en la nube si no existen).

### 2. Compilar e instalar la app en dispositivo/emulador

**Android**

```bash
npm run android
```

Conecta un dispositivo por USB con depuración USB o arranca un emulador. La app se compila e instala y luego arranca el bundler.

**iOS (solo macOS)**

```bash
npm run ios
```

### 3. Arrancar el bundler (si no se abrió solo)

```bash
npm start
```

El script `start` usa `--dev-client` para que la app instalada (development build) se conecte a este servidor.

## Builds en la nube (EAS Build)

Si no quieres compilar en local, usa EAS:

1. Instala EAS CLI y entra con tu cuenta Expo:

   ```bash
   npm install -g eas-cli
   eas login
   ```

2. Configura el proyecto (si no existe `eas.json`):

   ```bash
   eas build:configure
   ```

3. Build de desarrollo (APK en Android, app para simulador en iOS):

   ```bash
   npm run build:dev:android
   # o
   npm run build:dev:ios
   ```

   O con EAS directamente:

   ```bash
   eas build --profile development --platform android
   eas build --profile development --platform ios
   ```

4. Descarga el instalable desde el enlace que muestra EAS o desde [expo.dev](https://expo.dev) → tu proyecto → Builds. Instálalo en el dispositivo y luego ejecuta `npm start` en tu máquina para conectar la app al bundler.

## Perfiles de build (`eas.json`)

- **development**: build con dev client (depuración, distribución interna).
- **preview**: para pruebas internas (APK / IPA).
- **production**: para publicar (AAB en Android, IPA en iOS).

## Credenciales de login demo

- Usuario: `demo`  
- PIN: `123456`
