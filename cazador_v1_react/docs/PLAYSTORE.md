# Publicar cazador_v1_react en Google Play Store

Pasos para generar el AAB, configurar Play Console y subir la app.

---

## 1. Requisitos previos

- Cuenta en [Expo](https://expo.dev) (gratuita sirve para builds).
- Cuenta en [Google Play Console](https://play.google.com/console) (pago único ~25 USD).
- [EAS CLI](https://docs.expo.dev/build/setup/) instalado: `npm install -g eas-cli`.
- Iniciar sesión: `eas login`.

---

## 2. Configurar el proyecto para producción

### 2.1 Identificador de paquete (package name)

En `app.json` el paquete actual es `com.anonymous.cazador_v1_react`. Para Play Store conviene usar uno propio, por ejemplo:

- `pe.lotesenremate.cazador`
- `com.tuempresa.cazador`

Edita `app.json` → `expo.android.package`:

```json
"android": {
  "package": "pe.lotesenremate.cazador",
  ...
}
```

**Importante:** El package name no se puede cambiar después de publicar la primera versión.

### 2.2 Versión y número de versión

- **version** (en `app.json`): la que ve el usuario (ej. `1.0.0`).
- **versionCode** (Android): entero que debe subir en cada subida a Play. Añade en `app.json`:

```json
"android": {
  "package": "pe.lotesenremate.cazador",
  "versionCode": 1,
  ...
}
```

En futuras publicaciones sube `versionCode` (2, 3, …) y opcionalmente `version` (1.0.1, 1.1.0, etc.).

### 2.3 Icono y gráficos

- **Icono:** `assets/icon.png` (1024×1024 recomendado).
- **Splash:** `assets/splash-icon.png`.
- **Android:** iconos adaptativos en `assets/android-icon-*.png`.

Comprueba que existan y se vean bien; Play Store también pedirá capturas y, si aplica, gráfico de función destacada.

---

## 3. Generar el AAB con EAS Build

El perfil **production** en `eas.json` ya está configurado para generar **Android App Bundle (AAB)**, que es lo que pide Play Store.

### 3.1 Primera vez: configurar EAS

En la raíz del proyecto:

```bash
cd cazador_v1_react
eas build:configure
```

Si te pregunta por credenciales de Android, elige **Let EAS manage** para que Expo genere y guarde la keystore.

### 3.2 Build de producción para Android

```bash
eas build --profile production --platform android
```

- Se sube el código a los servidores de Expo y se genera el AAB.
- Al terminar verás un enlace para **descargar el .aab**.

Descarga el archivo y guárdalo (por ejemplo `app-release.aab`).

### 3.3 (Opcional) Build local

Si prefieres compilar en tu máquina en lugar de EAS:

```bash
npx expo prebuild
cd android
./gradlew bundleRelease
```

El AAB estará en `android/app/build/outputs/bundle/release/`. En ese caso tú debes gestionar la firma (keystore) y el `versionCode` en el proyecto Android.

---

## 4. Crear la app en Google Play Console

1. Entra en [Google Play Console](https://play.google.com/console).
2. **Crear app** (o elegir organización).
3. Rellena:
   - Nombre de la app (ej. "Veridian" o "Cazador").
   - Idioma por defecto.
   - Tipo (App o Juego).
   - Si es gratuita o de pago.
4. Acepta políticas (Privacidad, Contenido, etc.) y completa la verificación de la cuenta si aún no está hecha.

---

## 5. Rellenar la ficha de la tienda

En Play Console, en tu app:

### 5.1 Ficha principal de la tienda

- **Descripción breve** (máx. 80 caracteres).
- **Descripción completa** (máx. 4000 caracteres).
- **Icono:** 512×512 px.
- **Gráfico de función destacada:** 1024×500 px (opcional pero recomendado).
- **Capturas de pantalla:** al menos 2 (móvil). Tamaño típico 1080×1920 o similar. Puedes usar un emulador o dispositivo con la app instalada.

### 5.2 Clasificación de contenido

- Completa el cuestionario de clasificación (edad, contenido, etc.).
- Si la app recoge datos (correo, teléfono, etc.), configura la **Política de privacidad** y enlázala en la ficha.

### 5.3 Público objetivo y noticias

- Indica si la app va dirigida a niños o no.
- Rellena datos de contacto (email de soporte).

---

## 6. Subir el AAB

1. En Play Console: **Producción** (o **Pruebas internas** / **Pruebas cerradas** para probar antes).
2. **Crear nueva versión**.
3. Sube el archivo **.aab** descargado de EAS (o el que generaste en local).
4. En **Notas de la versión**, escribe los cambios (ej. "Versión inicial").
5. Guarda y, cuando todo esté listo, **Enviar para revisión**.

---

## 7. Envío a revisión

- Google revisa la app (suele tardar desde horas hasta varios días).
- Revisa que no haya errores en la consola (permisos, políticas, contenido).
- Cuando esté aprobada, la app quedará publicada (o en la pestaña que hayas elegido: producción, pruebas, etc.).

---

## Resumen de comandos

```bash
# 1. Instalar EAS y entrar
npm install -g eas-cli
eas login

# 2. En la carpeta del proyecto
cd cazador_v1_react

# 3. (Primera vez) Configurar build
eas build:configure

# 4. Generar AAB para Play Store
eas build --profile production --platform android

# 5. (Opcional) Enviar a Play Store con EAS Submit
eas submit --platform android --latest
```

Para **EAS Submit** (`eas submit`) necesitas tener en Play Console una app creada y, la primera vez, un **service account** con acceso a la API de Play para automatizar la subida. Si prefieres, puedes subir el AAB manualmente desde la consola web.

---

## Scripts útiles en package.json

Puedes añadir:

```json
"scripts": {
  "build:prod:android": "eas build --profile production --platform android",
  "submit:android": "eas submit --platform android --latest"
}
```

Así:

- `npm run build:prod:android` → genera el AAB de producción.
- `npm run submit:android` → sube el último build a Play (tras configurar credenciales).

---

## Referencias

- [Expo: Build for app stores](https://docs.expo.dev/build-reference/app-stores/)
- [Expo: EAS Submit](https://docs.expo.dev/submit/introduction/)
- [Google Play: Publicar apps](https://support.google.com/googleplay/android-developer/answer/9859152)
