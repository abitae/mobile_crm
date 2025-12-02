# API Datero - Perfil

## 📋 Descripción

Endpoints para gestionar el perfil del datero autenticado.

## 👤 Endpoints

### 1. Obtener Perfil

Obtiene la información del perfil del datero autenticado.

**Endpoint**: `GET /api/datero/profile`

**URL Completa**: `https://tu-dominio.com/api/datero/profile`

**Autenticación**: Requerida (Bearer Token)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/datero/profile" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Perfil obtenido exitosamente",
  "data": {
    "id": 123,
    "name": "Juan Pérez",
    "email": "juan.perez@example.com",
    "phone": "987654321",
    "role": "datero",
    "is_active": true,
    "banco": "BCP",
    "cuenta_bancaria": "1234567890",
    "cci_bancaria": "12345678901234567890"
  }
}
```

---

### 2. Actualizar Perfil

Actualiza la información del perfil del datero autenticado. Solo se actualizan los campos proporcionados.

**Endpoint**: `PUT /api/datero/profile` o `PATCH /api/datero/profile`

**URL Completa**: `https://tu-dominio.com/api/datero/profile`

**Autenticación**: Requerida (Bearer Token)

#### Parámetros (todos opcionales, solo enviar los que se desean actualizar)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | No | Nombre completo |
| `email` | string | No | Email (debe ser único) |
| `phone` | string | No | Teléfono de contacto |
| `banco` | string | No | Nombre del banco |
| `cuenta_bancaria` | string | No | Número de cuenta bancaria |
| `cci_bancaria` | string | No | Código CCI bancario |

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X PUT "https://tu-dominio.com/api/datero/profile" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez García",
    "phone": "987654322",
    "banco": "Interbank",
    "cuenta_bancaria": "9876543210",
    "cci_bancaria": "98765432109876543210"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Perfil actualizado exitosamente",
  "data": {
    "id": 123,
    "name": "Juan Pérez García",
    "email": "juan.perez@example.com",
    "phone": "987654322",
    "banco": "Interbank",
    "cuenta_bancaria": "9876543210",
    "cci_bancaria": "98765432109876543210"
  }
}
```

#### Respuesta de Error (422)

```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "email": ["Este email ya está en uso."]
  }
}
```

---

## 🔒 Restricciones

- **No se puede cambiar el DNI**: El DNI es inmutable por seguridad
- **No se puede cambiar el PIN desde aquí**: Usa el endpoint `/api/datero/auth/change-pin` para cambiar el PIN
- **Email único**: Si cambias el email, debe ser único en el sistema
- **Solo tu perfil**: Solo puedes actualizar tu propio perfil

## 📝 Notas Importantes

1. **Actualización parcial**: Solo necesitas enviar los campos que deseas actualizar
2. **Email único**: El email debe ser único en el sistema, no puede estar en uso por otro usuario
3. **Datos bancarios**: Los datos bancarios son opcionales y se usan para el pago de comisiones
4. **Validación**: Todos los campos son validados antes de actualizar

## 🔄 Cambio de PIN

Para cambiar el PIN, usa el endpoint de autenticación:

**Endpoint**: `POST /api/datero/auth/change-pin`

Ver documentación completa en [AUTH.md](./AUTH.md#6-cambiar-pin)

