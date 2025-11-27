# API Cazador - Autenticación

## 📋 Descripción

Endpoints para autenticación, gestión de sesión y perfil de usuario.

## 🔐 Endpoints

### 1. Iniciar Sesión

Inicia sesión y obtiene un token JWT.

**Endpoint**: `POST /api/cazador/auth/login`

**Autenticación**: No requerida

**Rate Limit**: 5 requests por minuto

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `email` | string | Sí | Email del usuario |
| `password` | string | Sí | Contraseña (mínimo 6 caracteres) |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "cazador@example.com",
    "password": "password123"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Inicio de sesión exitoso",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "name": "Juan Pérez",
      "email": "cazador@example.com",
      "phone": "+51987654321",
      "role": "Cazador",
      "is_active": true
    }
  }
}
```

#### Errores Posibles

- **400**: Credenciales inválidas
- **403**: Usuario no tiene permiso para acceder (rol incorrecto o cuenta inactiva)
- **422**: Error de validación
- **500**: Error del servidor

---

### 2. Obtener Usuario Autenticado

Obtiene la información del usuario autenticado.

**Endpoint**: `GET /api/cazador/auth/me`

**Autenticación**: Requerida (JWT)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X GET https://tu-dominio.com/api/cazador/auth/me \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "cazador@example.com",
    "phone": "+51987654321",
    "role": "Cazador",
    "is_active": true
  }
}
```

#### Errores Posibles

- **401**: No autenticado o token inválido
- **500**: Error del servidor

---

### 3. Cerrar Sesión

Invalida el token JWT actual.

**Endpoint**: `POST /api/cazador/auth/logout`

**Autenticación**: Requerida (JWT)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/auth/logout \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

#### Errores Posibles

- **401**: No autenticado o token inválido
- **500**: Error del servidor

---

### 4. Renovar Token

Renueva el token JWT actual.

**Endpoint**: `POST /api/cazador/auth/refresh`

**Autenticación**: Requerida (JWT)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/auth/refresh \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Token renovado exitosamente",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

#### Errores Posibles

- **401**: Token inválido o expirado
- **500**: Error del servidor

---

### 5. Cambiar Contraseña

Cambia la contraseña del usuario autenticado.

**Endpoint**: `POST /api/cazador/auth/change-password`

**Autenticación**: Requerida (JWT)

#### Headers

```
Authorization: Bearer {token}
```

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `current_password` | string | Sí | Contraseña actual |
| `new_password` | string | Sí | Nueva contraseña (mínimo 6 caracteres) |
| `new_password_confirmation` | string | Sí | Confirmación de nueva contraseña |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/auth/change-password \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "current_password": "password123",
    "new_password": "newpassword456",
    "new_password_confirmation": "newpassword456"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente"
}
```

#### Errores Posibles

- **401**: No autenticado o token inválido
- **422**: Error de validación (contraseña actual incorrecta, nueva contraseña no coincide, etc.)
- **500**: Error del servidor

---

## 🔒 Seguridad

### Validaciones de Acceso

1. **Rol permitido**: Solo usuarios con rol Administrador, Líder o Cazador pueden acceder
2. **Cuenta activa**: El usuario debe estar activo
3. **Token válido**: El token JWT debe ser válido y no expirado

### Logging

Todas las operaciones de autenticación se registran en los logs del sistema:
- Intentos de login exitosos y fallidos
- Cambios de contraseña
- Accesos con roles incorrectos
- Intentos con cuentas inactivas

---

## 📝 Notas Importantes

1. **Expiración del Token**: Los tokens JWT tienen un tiempo de expiración configurado (por defecto 60 minutos)
2. **Renovación**: Usa el endpoint `/refresh` antes de que expire el token
3. **Seguridad**: Nunca compartas tu token JWT
4. **Rate Limiting**: El endpoint de login tiene un límite más restrictivo (5 requests/minuto)

---

**Última actualización**: 2024-01-01

