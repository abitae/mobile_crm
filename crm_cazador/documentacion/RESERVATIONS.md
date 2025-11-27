# API Cazador - Reservas

## 📋 Descripción

Endpoints para gestionar reservas inmobiliarias. Los cazadores pueden crear, editar, confirmar, cancelar y convertir reservas a ventas. Solo pueden gestionar sus propias reservas (excepto administradores y líderes que ven todas).

## 🎫 Endpoints

### 1. Listar Reservas

Obtiene una lista paginada de reservas del cazador autenticado.

**Endpoint**: `GET /api/cazador/reservations`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Parámetros de Query

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `per_page` | integer | No | Elementos por página (máximo 100, por defecto 15) |
| `page` | integer | No | Número de página (por defecto 1) |
| `search` | string | No | Búsqueda en número de reserva, nombre de cliente o proyecto |
| `status` | string | No | Estado de reserva (activa, confirmada, cancelada, vencida, convertida_venta) |
| `payment_status` | string | No | Estado de pago (pendiente, pagado, parcial) |
| `project_id` | integer | No | Filtrar por proyecto |
| `client_id` | integer | No | Filtrar por cliente |
| `advisor_id` | integer | No | Filtrar por asesor (solo admin/líder) |

> ⚠️ **Nota**: Los cazadores normales solo ven sus propias reservas. Los administradores y líderes ven todas las reservas.

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/cazador/reservations?status=activa&per_page=20" \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reservas obtenidas exitosamente",
  "data": {
    "reservations": [
      {
        "id": 1,
        "reservation_number": "RES-2024-000001",
        "client_id": 5,
        "project_id": 2,
        "unit_id": 10,
        "advisor_id": 3,
        "reservation_type": "pre_reserva",
        "status": "activa",
        "reservation_date": "2024-01-15",
        "expiration_date": "2024-02-15",
        "reservation_amount": 50000.00,
        "reservation_percentage": 10.00,
        "payment_method": "transferencia",
        "payment_status": "pendiente",
        "payment_reference": "TRF-123456",
        "notes": "Cliente interesado en lote de 300m²",
        "terms_conditions": null,
        "image": null,
        "image_url": null,
        "client_signature": false,
        "advisor_signature": false,
        "is_active": true,
        "is_confirmed": false,
        "is_cancelled": false,
        "is_expired": false,
        "is_converted": false,
        "is_expiring_soon": false,
        "days_until_expiration": 30,
        "status_color": "green",
        "payment_status_color": "yellow",
        "formatted_reservation_amount": "50,000.00",
        "formatted_reservation_percentage": "10.00%",
        "can_be_confirmed": false,
        "can_be_cancelled": true,
        "can_be_converted": false,
        "client": {
          "id": 5,
          "name": "Carlos Rodríguez",
          "phone": "+51987654321"
        },
        "project": {
          "id": 2,
          "name": "Proyecto Los Olivos"
        },
        "unit": {
          "id": 10,
          "unit_manzana": "A",
          "unit_number": "Lote-001",
          "full_identifier": "Proyecto Los Olivos - Unidad Lote-001"
        },
        "advisor": {
          "id": 3,
          "name": "Juan Pérez",
          "email": "juan@example.com"
        },
        "created_at": "2024-01-15 10:00:00",
        "updated_at": "2024-01-15 10:00:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 45,
      "last_page": 3,
      "from": 1,
      "to": 20
    }
  }
}
```

---

### 2. Obtener Reserva Específica

Obtiene los detalles completos de una reserva específica.

**Endpoint**: `GET /api/cazador/reservations/{id}`

**Autenticación**: Requerida (JWT)

#### Ejemplo de Solicitud

```bash
curl -X GET https://tu-dominio.com/api/cazador/reservations/1 \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reserva obtenida exitosamente",
  "data": {
    "reservation": {
      "id": 1,
      "reservation_number": "RES-2024-000001",
      // ... todos los campos de la reserva ...
      "client": {
        "id": 5,
        "name": "Carlos Rodríguez",
        "phone": "+51987654321",
        "document_type": "dni",
        "document_number": "12345678"
      },
      "project": {
        "id": 2,
        "name": "Proyecto Los Olivos",
        "address": "Av. Principal 123",
        "district": "Los Olivos",
        "province": "Lima"
      },
      "unit": {
        "id": 10,
        "unit_manzana": "A",
        "unit_number": "Lote-001",
        "area": 300.50,
        "final_price": 500000.00
      }
    }
  }
}
```

#### Errores Posibles

- **400**: ID de reserva inválido
- **401**: No autenticado
- **403**: No tienes permiso para acceder a esta reserva
- **404**: Reserva no encontrada
- **500**: Error del servidor

---

### 3. Crear Reserva

Crea una nueva reserva. La reserva se crea con estado `activa` y la unidad permanece disponible hasta que se confirme con imagen.

**Endpoint**: `POST /api/cazador/reservations`

**Autenticación**: Requerida (JWT)

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `client_id` | integer | Sí | ID del cliente |
| `project_id` | integer | Sí | ID del proyecto |
| `unit_id` | integer | Sí | ID de la unidad (debe estar disponible) |
| `advisor_id` | integer | Sí | ID del asesor |
| `reservation_date` | date | Sí | Fecha de reserva (formato: YYYY-MM-DD) |
| `expiration_date` | date | No | Fecha de vencimiento (debe ser posterior a reservation_date) |
| `reservation_amount` | decimal | Sí | Monto de reserva (mínimo 0) |
| `reservation_percentage` | decimal | No | Porcentaje del precio total (0-100) |
| `payment_method` | string | No | Método de pago |
| `payment_reference` | string | No | Referencia de pago |
| `notes` | string | No | Notas adicionales |
| `terms_conditions` | string | No | Términos y condiciones |

> ⚠️ **Importante**: 
> - La unidad debe estar disponible
> - El estado se fuerza a `activa`
> - El estado de pago se fuerza a `pendiente`
> - El tipo se fuerza a `pre_reserva`
> - La unidad NO se reserva hasta que se confirme con imagen

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/reservations \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": 5,
    "project_id": 2,
    "unit_id": 10,
    "advisor_id": 3,
    "reservation_date": "2024-01-15",
    "expiration_date": "2024-02-15",
    "reservation_amount": 50000.00,
    "reservation_percentage": 10.00,
    "payment_method": "transferencia",
    "payment_reference": "TRF-123456",
    "notes": "Cliente interesado en lote de 300m²"
  }'
```

#### Respuesta Exitosa (201)

```json
{
  "success": true,
  "message": "Reserva creada exitosamente. Para confirmarla, sube la imagen del comprobante de pago.",
  "data": {
    "reservation": {
      "id": 1,
      "reservation_number": "RES-2024-000001",
      "status": "activa",
      "payment_status": "pendiente",
      // ... resto de campos ...
    }
  }
}
```

#### Errores Posibles

- **401**: No autenticado
- **404**: Cliente, proyecto o unidad no encontrados
- **422**: Error de validación o unidad no disponible
- **500**: Error del servidor

---

### 4. Actualizar Reserva

Actualiza una reserva existente. Solo se pueden actualizar reservas con estado `activa`.

**Endpoint**: `PUT /api/cazador/reservations/{id}` o `PATCH /api/cazador/reservations/{id}`

**Autenticación**: Requerida (JWT)

> ⚠️ **Restricciones**:
> - Solo se pueden editar reservas con estado `activa`
> - No se pueden cambiar `project_id` ni `unit_id`
> - El estado se mantiene automáticamente

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `client_id` | integer | No | ID del cliente |
| `advisor_id` | integer | No | ID del asesor |
| `reservation_type` | string | No | Tipo de reserva |
| `reservation_date` | date | No | Fecha de reserva |
| `expiration_date` | date | No | Fecha de vencimiento |
| `reservation_amount` | decimal | No | Monto de reserva |
| `reservation_percentage` | decimal | No | Porcentaje (0-100) |
| `payment_method` | string | No | Método de pago |
| `payment_status` | string | No | Estado de pago |
| `payment_reference` | string | No | Referencia de pago |
| `notes` | string | No | Notas |
| `terms_conditions` | string | No | Términos y condiciones |

#### Ejemplo de Solicitud

```bash
curl -X PUT https://tu-dominio.com/api/cazador/reservations/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "reservation_amount": 60000.00,
    "reservation_percentage": 12.00,
    "payment_status": "parcial",
    "notes": "Cliente realizó pago parcial"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reserva actualizada exitosamente",
  "data": {
    "reservation": {
      // ... reserva actualizada ...
    }
  }
}
```

#### Errores Posibles

- **400**: ID de reserva inválido
- **401**: No autenticado
- **403**: No tienes permiso para actualizar esta reserva
- **404**: Reserva no encontrada
- **422**: Solo se pueden editar reservas activas o error de validación
- **500**: Error del servidor

---

### 5. Confirmar Reserva

Confirma una reserva subiendo la imagen del comprobante de pago. Esto cambia el estado a `confirmada` y marca la unidad como `reservado`.

**Endpoint**: `POST /api/cazador/reservations/{id}/confirm`

**Autenticación**: Requerida (JWT)

> ⚠️ **Importante**: 
> - Solo se pueden confirmar reservas con estado `activa`
> - La imagen es obligatoria
> - Al confirmar, la unidad se marca como `reservado`
> - El estado cambia automáticamente a `confirmada`

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `image` | file | Sí | Imagen del comprobante (jpeg, png, jpg, gif, webp, máx 10MB) |
| `reservation_date` | date | No | Fecha de reserva (actualizar) |
| `expiration_date` | date | No | Fecha de vencimiento (actualizar) |
| `reservation_amount` | decimal | No | Monto de reserva (actualizar) |
| `reservation_percentage` | decimal | No | Porcentaje (actualizar) |
| `payment_method` | string | No | Método de pago (actualizar) |
| `payment_status` | string | No | Estado de pago (actualizar) |
| `payment_reference` | string | No | Referencia de pago (actualizar) |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/reservations/1/confirm \
  -H "Authorization: Bearer {token}" \
  -F "image=@/ruta/a/comprobante.jpg" \
  -F "payment_status=pagado" \
  -F "payment_method=transferencia" \
  -F "payment_reference=TRF-123456"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reserva confirmada exitosamente. La unidad ha sido marcada como reservada.",
  "data": {
    "reservation": {
      "id": 1,
      "status": "confirmada",
      "image": "reservations/abc123.jpg",
      "image_url": "https://tu-dominio.com/storage/reservations/abc123.jpg",
      // ... resto de campos ...
    }
  }
}
```

#### Errores Posibles

- **400**: ID de reserva inválido
- **401**: No autenticado
- **403**: No tienes permiso para confirmar esta reserva
- **404**: Reserva no encontrada
- **422**: Solo se pueden confirmar reservas activas o error de validación
- **500**: Error del servidor

---

### 6. Cancelar Reserva

Cancela una reserva con una nota obligatoria. Libera la unidad a estado `disponible`.

**Endpoint**: `POST /api/cazador/reservations/{id}/cancel`

**Autenticación**: Requerida (JWT)

> ⚠️ **Importante**: 
> - Solo se pueden cancelar reservas con estado `activa` o `confirmada`
> - La nota de cancelación es obligatoria (mínimo 10 caracteres)
> - Al cancelar, la unidad se libera a `disponible`

#### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `cancel_note` | string | Sí | Nota de cancelación (10-500 caracteres) |

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/reservations/1/cancel \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "cancel_note": "Cliente decidió no continuar con la compra por motivos personales"
  }'
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reserva cancelada exitosamente. La unidad ha sido liberada.",
  "data": {
    "reservation": {
      "id": 1,
      "status": "cancelada",
      "notes": "...\n\n[Cancelada] Cliente decidió no continuar...",
      // ... resto de campos ...
    }
  }
}
```

#### Errores Posibles

- **400**: ID de reserva inválido
- **401**: No autenticado
- **403**: No tienes permiso para cancelar esta reserva
- **404**: Reserva no encontrada
- **422**: La reserva no puede ser cancelada o error de validación
- **500**: Error del servidor

---

### 7. Convertir Reserva a Venta

Convierte una reserva confirmada a una venta (Opportunity). Marca la unidad como `vendido`.

**Endpoint**: `POST /api/cazador/reservations/{id}/convert-to-sale`

**Autenticación**: Requerida (JWT)

> ⚠️ **Importante**: 
> - Solo se pueden convertir reservas con estado `confirmada`
> - Crea o actualiza una Opportunity con status `pagado`
> - Marca la unidad como `vendido`
> - Estado final: `convertida_venta`

#### Ejemplo de Solicitud

```bash
curl -X POST https://tu-dominio.com/api/cazador/reservations/1/convert-to-sale \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Reserva convertida a venta exitosamente. La unidad ha sido marcada como vendida.",
  "data": {
    "reservation": {
      "id": 1,
      "status": "convertida_venta",
      // ... resto de campos ...
    }
  }
}
```

#### Errores Posibles

- **400**: ID de reserva inválido
- **401**: No autenticado
- **403**: No tienes permiso para convertir esta reserva
- **404**: Reserva no encontrada
- **422**: Solo se pueden convertir reservas confirmadas o unidad no puede venderse
- **500**: Error del servidor

---

## 📊 Estados de Reserva

### Estados Disponibles

| Estado | Descripción | Acciones Permitidas |
|--------|-------------|---------------------|
| `activa` | Reserva creada sin comprobante | Editar, Confirmar, Cancelar |
| `confirmada` | Reserva con comprobante subido | Convertir a Venta, Cancelar |
| `cancelada` | Reserva cancelada | Solo visualización |
| `vencida` | Reserva expirada | Solo visualización |
| `convertida_venta` | Convertida a venta | Solo visualización |

### Transiciones de Estado

```
activa → confirmada (al subir imagen)
activa → cancelada (al cancelar)
confirmada → convertida_venta (al convertir)
confirmada → cancelada (al cancelar)
```

---

## 🔒 Permisos y Restricciones

### Reglas de Acceso

1. **Cazadores normales**: Solo pueden ver y gestionar sus propias reservas (`advisor_id = user_id`)
2. **Administradores y Líderes**: Pueden ver y gestionar todas las reservas
3. **Edición**: Solo reservas con estado `activa`
4. **Confirmación**: Solo reservas con estado `activa`
5. **Cancelación**: Solo reservas con estado `activa` o `confirmada`
6. **Conversión**: Solo reservas con estado `confirmada`

### Validaciones Importantes

- **Unidad disponible**: Al crear, la unidad debe estar disponible
- **Proyecto/Unidad**: No se pueden cambiar después de crear
- **Imagen obligatoria**: Para confirmar, se requiere imagen del comprobante
- **Nota de cancelación**: Obligatoria y mínimo 10 caracteres
- **Fechas**: La fecha de vencimiento debe ser posterior a la fecha de reserva

---

## 📝 Notas Importantes

1. **Estado inicial**: Las reservas se crean siempre con estado `activa` y `payment_status` `pendiente`
2. **Unidad disponible**: La unidad permanece disponible hasta que se confirme con imagen
3. **Confirmación**: Al confirmar, la unidad se marca como `reservado` automáticamente
4. **Cancelación**: Al cancelar, la unidad se libera a `disponible`
5. **Conversión**: Al convertir, se crea/actualiza una Opportunity y la unidad se marca como `vendido`
6. **Número de reserva**: Se genera automáticamente con formato `RES-YYYY-NNNNNN`
7. **Imágenes**: Se almacenan en `storage/app/public/reservations`

---

**Última actualización**: 2024-01-01

