# API Datero - Autenticación

## 📋 Descripción

Endpoints para registro, autenticación con DNI y PIN, gestión de sesión y cambio de PIN.

## 🔐 Endpoints

### 1. Registro de Datero

Registra un nuevo usuario datero en el sistema. El datero será asignado automáticamente al cazador/líder especificado.

**Endpoint**: `POST /api/datero/auth/register`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/register`

**Autenticación**: No requerida

**Rate Limit**: 3 requests por minuto

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | Sí | Nombre completo del datero |
| `email` | string | Sí | Email único del datero |
| `phone` | string | Sí | Teléfono de contacto |
| `dni` | string | Sí | DNI único (8 dígitos) |
| `pin` | string | Sí | PIN de 6 dígitos numéricos |
| `lider_id` | integer | Sí | ID del cazador/líder al que se asigna |
| `banco` | string | No | Nombre del banco |
| `cuenta_bancaria` | string | No | Número de cuenta bancaria |
| `cci_bancaria` | string | No | Código CCI bancario |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/datero/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan.perez@example.com",
    "phone": "987654321",
    "dni": "12345678",
    "pin": "123456",
    "lider_id": 5,
    "banco": "BCP",
    "cuenta_bancaria": "1234567890",
    "cci_bancaria": "12345678901234567890"
  }'
```

#### Respuesta Exitosa (201)

```json
{
  "success": true,
  "message": "Registro exitoso. Bienvenido.",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 123,
      "name": "Juan Pérez",
      "email": "juan.perez@example.com",
      "phone": "987654321",
      "dni": "12345678",
      "role": "datero",
      "is_active": true,
      "lider": {
        "id": 5,
        "name": "Carlos García",
        "email": "carlos@example.com"
      }
    }
  }
}
```

#### Respuesta de Error (422)

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "dni": ["Este DNI ya está registrado."],
    "pin": ["El PIN debe tener exactamente 6 dígitos."]
  }
}
```

---

### 2. Iniciar Sesión

Inicia sesión usando DNI y PIN. Retorna un token JWT para usar en las siguientes peticiones.

**Endpoint**: `POST /api/datero/auth/login`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/login`

**Autenticación**: No requerida

**Rate Limit**: 5 requests por minuto

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `dni` | string | Sí | DNI del usuario |
| `pin` | string | Sí | PIN de 6 dígitos numéricos |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/datero/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "dni": "12345678",
    "pin": "123456"
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
      "id": 123,
      "name": "Juan Pérez",
      "email": "juan.perez@example.com",
      "phone": "987654321",
      "dni": "12345678",
      "role": "datero",
      "is_active": true
    }
  }
}
```

#### Respuesta de Error (401)

```json
{
  "success": false,
  "message": "Credenciales inválidas"
}
```

---

### 3. Obtener Usuario Autenticado

Obtiene la información del usuario autenticado.

**Endpoint**: `GET /api/datero/auth/me`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/me`

**Autenticación**: Requerida (Bearer Token)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X GET https://tu-dominio.com/api/datero/auth/me \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Usuario obtenido exitosamente",
  "data": {
    "id": 123,
    "name": "Juan Pérez",
    "email": "juan.perez@example.com",
    "phone": "987654321",
    "dni": "12345678",
    "role": "datero",
    "is_active": true
  }
}
```

---

### 4. Cerrar Sesión

Invalida el token JWT actual, cerrando la sesión del usuario.

**Endpoint**: `POST /api/datero/auth/logout`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/logout`

**Autenticación**: Requerida (Bearer Token)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/datero/auth/logout \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente",
  "data": null
}
```

---

### 5. Renovar Token

Renueva el token JWT actual, obteniendo uno nuevo con tiempo de expiración extendido.

**Endpoint**: `POST /api/datero/auth/refresh`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/refresh`

**Autenticación**: Requerida (Bearer Token)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/datero/auth/refresh \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
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

---

### 6. Cambiar PIN

Permite cambiar el PIN del usuario autenticado. Requiere el PIN actual y el nuevo PIN.

**Endpoint**: `POST /api/datero/auth/change-pin`

**URL Completa**: `https://tu-dominio.com/api/datero/auth/change-pin`

**Autenticación**: Requerida (Bearer Token)

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `current_pin` | string | Sí | PIN actual (6 dígitos) |
| `new_pin` | string | Sí | Nuevo PIN (6 dígitos) |
| `new_pin_confirmation` | string | Sí | Confirmación del nuevo PIN |

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/datero/auth/change-pin \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "current_pin": "123456",
    "new_pin": "654321",
    "new_pin_confirmation": "654321"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "PIN actualizado exitosamente",
  "data": null
}
```

#### Respuesta de Error (422)

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "current_pin": ["El PIN actual es incorrecto."],
    "new_pin": ["El nuevo PIN debe ser diferente al PIN actual."]
  }
}
```

---

## 🔒 Seguridad

- El PIN se almacena hasheado en la base de datos
- El token JWT expira después de 1 hora (3600 segundos)
- Los intentos de login fallidos se registran en los logs
- Rate limiting protege contra ataques de fuerza bruta

## 📝 Notas Importantes

1. **DNI único**: Cada datero debe tener un DNI único en el sistema
2. **PIN de 6 dígitos**: El PIN debe contener exactamente 6 dígitos numéricos
3. **Asignación a cazador**: Al registrarse, el datero debe ser asignado a un cazador/líder válido
4. **Token JWT**: Guarda el token recibido en el login/registro para usarlo en peticiones posteriores
5. **Renovación de token**: Usa el endpoint `/refresh` antes de que el token expire

