# Configuración de Firma Digital - CRM Cazador

## ✅ Estado de la Configuración

La aplicación Android está configurada para ser firmada con el keystore ubicado en `key/keystore.jks`.

## 📁 Estructura de Archivos

```
crm_cazador/
├── key/
│   ├── keystore.jks          # Keystore de firma
│   └── .gitignore            # Ignora el keystore en git
└── android/
    └── key.properties        # Configuración de firma
```

## 🔑 Información del Keystore

**Ubicación:** `crm_cazador/key/keystore.jks`

**Configuración en `android/key.properties`:**
```properties
storePassword=abitae123
keyPassword=abitae123
keyAlias=abitae
storeFile=../key/keystore.jks
```

## 🔧 Configuración en build.gradle.kts

### 1. Carga de Propiedades
El archivo `build.gradle.kts` busca `key.properties` en:
1. `android/key.properties` (ubicación estándar)
2. Raíz del proyecto (fallback)
3. Directorio actual (fallback)

### 2. SigningConfigs
- ✅ Crea configuración `release` si encuentra el keystore
- ✅ Usa firma de debug como fallback si no encuentra el keystore
- ✅ Valida que el archivo keystore exista antes de usarlo

### 3. BuildTypes
- **Debug**: Usa firma de debug (automática)
- **Profile**: Usa firma de debug (automática)
- **Release**: Usa el keystore configurado si está disponible

## 🔒 Verificación

### Verificar que el keystore existe:
```powershell
Test-Path "crm_cazador\key\keystore.jks"
```

### Verificar que key.properties existe:
```powershell
Test-Path "crm_cazador\android\key.properties"
```

### Verificar información del keystore:
```bash
keytool -list -v -keystore crm_cazador/key/keystore.jks
```

## 📦 Compilación Firmada

### Build Debug (firma automática):
```bash
flutter build apk --debug
```

### Build Profile (firma automática):
```bash
flutter build apk --profile
```

### Build Release (firma con keystore):
```bash
flutter build apk --release
```

### Build App Bundle (firma con keystore):
```bash
flutter build appbundle --release
```

## ⚠️ Notas Importantes

1. **Seguridad**: El archivo `key.properties` está en `.gitignore` y NO debe subirse a git
2. **Keystore**: El archivo `keystore.jks` está en `.gitignore` y NO debe subirse a git
3. **Contraseñas**: Mantén las contraseñas seguras y no las compartas
4. **Backup**: Haz backup del keystore en un lugar seguro

## 🐛 Troubleshooting

### Si el build falla con error de firma:

1. **Verificar que el keystore existe:**
   ```powershell
   Test-Path "crm_cazador\key\keystore.jks"
   ```

2. **Verificar que key.properties existe:**
   ```powershell
   Test-Path "crm_cazador\android\key.properties"
   ```

3. **Verificar la ruta en key.properties:**
   - Debe ser relativa: `../key/keystore.jks`
   - O absoluta: `E:\PROYECTOS_FLUTTER\mobile_crm\crm_cazador\key\keystore.jks`

4. **Verificar contraseñas:**
   - Asegúrate de que `storePassword` y `keyPassword` sean correctas
   - Asegúrate de que `keyAlias` sea correcto

5. **Limpiar y reconstruir:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## ✅ Logs de Verificación

Durante la compilación, deberías ver:
- `✅ Keystore properties cargadas desde: [ruta]`
- `✅ Configuración de firma release creada con keystore: [ruta]`

Si hay problemas, verás:
- `⚠️ key.properties no encontrado. Usando firma de debug para release.`
- `⚠️ Keystore no encontrado en: [ruta]`
- `⚠️ Propiedades de keystore incompletas en key.properties`

---

**Última actualización**: 2025-01-09
**Estado**: ✅ Configurado y funcionando
