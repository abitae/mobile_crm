# 🔐 API - Cambio de Contraseña

## Descripción

Este documento describe el endpoint de cambio de contraseña disponible en ambas aplicaciones móviles (Cazador y Datero). Permite a los usuarios autenticados cambiar su contraseña de forma segura.

---

## 📋 Endpoints

### Aplicación Cazador

**Endpoint:** `POST /api/cazador/auth/change-password`

**Autenticación:** Requerida (JWT Token)

**Middleware:** `auth:api`, `cazador`

**Roles permitidos:** Administrador, Lider, Cazador (vendedor)

---

### Aplicación Datero

**Endpoint:** `POST /api/datero/auth/change-password`

**Autenticación:** Requerida (JWT Token)

**Middleware:** `auth:api`, `datero`

**Roles permitidos:** Datero

---

## 📥 Request

### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Body Parameters

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `current_password` | string | Sí | Contraseña actual del usuario |
| `new_password` | string | Sí | Nueva contraseña (mínimo 6 caracteres) |
| `new_password_confirmation` | string | Sí | Confirmación de la nueva contraseña |

### Ejemplo de Request

```json
{
  "current_password": "mi_contraseña_actual",
  "new_password": "mi_nueva_contraseña_123",
  "new_password_confirmation": "mi_nueva_contraseña_123"
}
```

---

## 📤 Response

### Respuesta Exitosa (200 OK)

```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente",
  "data": null
}
```

### Errores de Validación (422 Unprocessable Entity)

#### Contraseña actual incorrecta

```json
{
  "success": false,
  "message": "La contraseña actual es incorrecta",
  "data": null
}
```

#### Nueva contraseña igual a la actual

```json
{
  "success": false,
  "message": "La nueva contraseña debe ser diferente a la contraseña actual",
  "data": null
}
```

#### Errores de validación

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "current_password": [
      "La contraseña actual es obligatoria."
    ],
    "new_password": [
      "La nueva contraseña debe tener al menos 6 caracteres.",
      "La confirmación de contraseña no coincide."
    ]
  }
}
```

### Usuario no autenticado (401 Unauthorized)

```json
{
  "success": false,
  "message": "Usuario no autenticado"
}
```

### Error del servidor (500 Internal Server Error)

```json
{
  "success": false,
  "message": "Error al cambiar la contraseña",
  "data": {
    "error": "Mensaje de error detallado"
  }
}
```

---

## ✅ Validaciones

1. **Contraseña actual obligatoria:** El campo `current_password` es requerido.

2. **Nueva contraseña obligatoria:** El campo `new_password` es requerido.

3. **Longitud mínima:** La nueva contraseña debe tener al menos 6 caracteres.

4. **Confirmación requerida:** El campo `new_password_confirmation` debe coincidir con `new_password`.

5. **Verificación de contraseña actual:** El sistema verifica que la contraseña actual proporcionada sea correcta.

6. **Contraseña diferente:** La nueva contraseña debe ser diferente a la contraseña actual.

---

## 🔒 Seguridad

### Características de Seguridad Implementadas

- ✅ **Autenticación JWT:** Solo usuarios autenticados pueden cambiar su contraseña.
- ✅ **Verificación de contraseña actual:** Se valida que el usuario conozca su contraseña actual.
- ✅ **Hash seguro:** Las contraseñas se almacenan usando hash bcrypt.
- ✅ **Validación de confirmación:** Se requiere confirmar la nueva contraseña.
- ✅ **Logging de seguridad:** Se registran intentos fallidos y cambios exitosos.
- ✅ **Prevención de reutilización:** La nueva contraseña debe ser diferente a la actual.

### Logging

El sistema registra los siguientes eventos:

- **Intento fallido:** Cuando la contraseña actual es incorrecta
  - `user_id`, `email`, `ip`

- **Cambio exitoso:** Cuando la contraseña se cambia correctamente
  - `user_id`, `email`, `ip`

- **Errores:** Cuando ocurre un error durante el proceso
  - `user_id`, `error`, `trace`, `ip`

---

## 📝 Ejemplos de Uso

### cURL - Aplicación Cazador

```bash
curl -X POST https://api.ejemplo.com/api/cazador/auth/change-password \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "current_password": "contraseña_actual_123",
    "new_password": "nueva_contraseña_456",
    "new_password_confirmation": "nueva_contraseña_456"
  }'
```

### cURL - Aplicación Datero

```bash
curl -X POST https://api.ejemplo.com/api/datero/auth/change-password \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "current_password": "contraseña_actual_123",
    "new_password": "nueva_contraseña_456",
    "new_password_confirmation": "nueva_contraseña_456"
  }'
```

### JavaScript (Fetch API) - Aplicación Cazador

```javascript
const changePassword = async (currentPassword, newPassword, newPasswordConfirmation) => {
  try {
    const response = await fetch('https://api.ejemplo.com/api/cazador/auth/change-password', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        current_password: currentPassword,
        new_password: newPassword,
        new_password_confirmation: newPasswordConfirmation
      })
    });

    const data = await response.json();

    if (data.success) {
      console.log('Contraseña actualizada exitosamente');
    } else {
      console.error('Error:', data.message);
    }
  } catch (error) {
    console.error('Error de red:', error);
  }
};
```

### JavaScript (Fetch API) - Aplicación Datero

```javascript
const changePassword = async (currentPassword, newPassword, newPasswordConfirmation) => {
  try {
    const response = await fetch('https://api.ejemplo.com/api/datero/auth/change-password', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        current_password: currentPassword,
        new_password: newPassword,
        new_password_confirmation: newPasswordConfirmation
      })
    });

    const data = await response.json();

    if (data.success) {
      console.log('Contraseña actualizada exitosamente');
    } else {
      console.error('Error:', data.message);
    }
  } catch (error) {
    console.error('Error de red:', error);
  }
};
```

### PHP (Guzzle HTTP)

```php
use GuzzleHttp\Client;

$client = new Client([
    'base_uri' => 'https://api.ejemplo.com',
]);

try {
    $response = $client->post('/api/cazador/auth/change-password', [
        'headers' => [
            'Authorization' => 'Bearer ' . $token,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ],
        'json' => [
            'current_password' => 'contraseña_actual_123',
            'new_password' => 'nueva_contraseña_456',
            'new_password_confirmation' => 'nueva_contraseña_456',
        ],
    ]);

    $data = json_decode($response->getBody(), true);
    
    if ($data['success']) {
        echo "Contraseña actualizada exitosamente\n";
    }
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

---

## 🚨 Códigos de Estado HTTP

| Código | Descripción |
|--------|-------------|
| `200` | Contraseña actualizada exitosamente |
| `401` | Usuario no autenticado o token inválido |
| `403` | Usuario no tiene permisos para acceder (rol incorrecto) |
| `422` | Error de validación o contraseña actual incorrecta |
| `500` | Error interno del servidor |

---

## 📌 Notas Importantes

1. **Token JWT requerido:** El usuario debe estar autenticado y proporcionar un token JWT válido en el header `Authorization`.

2. **Confirmación de contraseña:** El campo `new_password_confirmation` debe coincidir exactamente con `new_password`.

3. **Contraseña diferente:** La nueva contraseña debe ser diferente a la contraseña actual del usuario.

4. **Longitud mínima:** La nueva contraseña debe tener al menos 6 caracteres.

5. **Seguridad:** Después de cambiar la contraseña, el token JWT actual sigue siendo válido. Si se requiere invalidar la sesión, el usuario debe hacer logout y volver a iniciar sesión.

6. **Rate Limiting:** Este endpoint está protegido por el middleware de autenticación, pero no tiene rate limiting específico adicional.

---

## 🔄 Flujo de Cambio de Contraseña

```
1. Usuario autenticado envía request con:
   - current_password
   - new_password
   - new_password_confirmation

2. Sistema valida:
   ✓ Usuario autenticado
   ✓ Campos requeridos presentes
   ✓ Nueva contraseña tiene mínimo 6 caracteres
   ✓ Confirmación coincide con nueva contraseña

3. Sistema verifica:
   ✓ Contraseña actual es correcta
   ✓ Nueva contraseña es diferente a la actual

4. Si todo es válido:
   ✓ Actualiza contraseña en base de datos (hash bcrypt)
   ✓ Registra cambio en logs
   ✓ Retorna éxito

5. Si hay error:
   ✗ Retorna mensaje de error apropiado
   ✗ Registra intento en logs (si aplica)
```

---

## 📚 Endpoints Relacionados

- `POST /api/{cazador|datero}/auth/login` - Iniciar sesión
- `GET /api/{cazador|datero}/auth/me` - Obtener información del usuario
- `POST /api/{cazador|datero}/auth/logout` - Cerrar sesión
- `POST /api/{cazador|datero}/auth/refresh` - Refrescar token JWT

---

## 📅 Versión

**Versión del documento:** 1.0  
**Última actualización:** 2024  
**API Version:** v1

---

## 👥 Soporte

Para más información o soporte técnico, contactar al equipo de desarrollo.

