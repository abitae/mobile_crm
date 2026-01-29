# API Cazador para Flutter (mensajes y manejo de errores)

Este documento resume los endpoints del API Cazador y enumera **todos los mensajes de error posibles** que devuelve el backend. Sirve como guía práctica para consumo desde Flutter.

## Base
- Base URL: `/api/cazador` (o `/api/v1/cazador`)
- Auth: JWT en `Authorization: Bearer <token>`

## Formato de respuesta

### Éxito
```json
{
  "success": true,
  "message": "Operacion exitosa",
  "data": { }
}
```

### Error (genérico)
```json
{
  "success": false,
  "message": "Mensaje de error",
  "errors": { }
}
```

### Error de validación (HTTP 422)
```json
{
  "success": false,
  "message": "Error de validación",
  "errors": {
    "campo": ["Mensaje de validación"]
  }
}
```

## Campos y validaciones clave (Clientes)
- `create_mode`: **obligatorio** `dni|phone`
- Modo `dni`: `document_type` y `document_number` **obligatorios**
- Modo `phone`: DNI **opcional**
- `phone`: **9 dígitos** iniciando en `9`, **único**
- `name`: **obligatorio**
- `birth_date`, `client_type`, `source`, `status`, `score`: **obligatorios**

## Duplicados (DNI / Teléfono)
Cuando un DNI o teléfono ya existe, el API devuelve:
- Mensaje: `Telefono registrado por "Nombre Vendedor"` o `DNI registrado por "Nombre Vendedor"`
- Campo adicional `duplicate_owner`:
```json
{
  "duplicate_owner": {
    "name": "Juan Perez",
    "user_id": 10,
    "client_id": 5,
    "field": "phone"
  }
}
```

## Endpoints y mensajes de error

### Auth
**POST** `/auth/login`
- `Error de validación` (422)
- `Credenciales inválidas` (401)
- `Acceso denegado. Solo usuarios Administrador, Lider o Cazador pueden acceder.` (403)
- `Tu cuenta está desactivada. Contacta al administrador.` (403)
- `Error al generar el token de acceso` (500)
- `Error al iniciar sesión` (500)

**GET** `/auth/me`
- `Usuario no autenticado` (401)
- `Error al obtener el usuario autenticado` (500)

**POST** `/auth/logout`
- `Error al cerrar sesión (token inválido)` (500)

**POST** `/auth/refresh`
- `Token inválido o expirado (no se pudo refrescar)` (401)

**POST** `/auth/change-password`
- `Usuario no autenticado` (401)
- `Error de validación` (422)
- `La contraseña actual es incorrecta` (422)
- `La nueva contraseña debe ser diferente a la contraseña actual` (422)
- `Error al actualizar la contraseña` (500)

---

### Clientes
**GET** `/clients`
- `Error al listar clientes del cazador` (500)

**GET** `/clients/{id}`
- `Cliente no encontrado` (404)
- `No tienes permiso para acceder a este cliente` (403)
- `Error al obtener el cliente solicitado` (500)

**POST** `/clients`
- `Error de validación` (422)
- `Telefono registrado por "Nombre"` (422)
- `DNI registrado por "Nombre"` (422)
- `Error al crear el cliente en Cazador` (500)

**PUT/PATCH** `/clients/{id}`
- `Cliente no encontrado` (404)
- `No tienes permiso para actualizar este cliente` (403)
- `Error al actualizar el cliente` (500)
- `Error de validación` (422)
- `Telefono registrado por "Nombre"` (422)
- `DNI registrado por "Nombre"` (422)
- `Error al actualizar el cliente en Cazador` (500)

**POST** `/clients/batch`
- `La lista de clientes es obligatoria` (422)
- Por item:
  - `Error de validación` (422)
  - `Telefono registrado por "Nombre"` (422)
  - `DNI registrado por "Nombre"` (422)

**GET** `/clients/batch?ids=1,2`
- `Se requieren IDs validos` (422)

**POST** `/clients/validate`
- Respuesta `success=true` con `valid=false`
- Mensaje: `Validacion de cliente fallida` o `Telefono registrado por "Nombre"` / `DNI registrado por "Nombre"`

**GET** `/clients/options`
- `Error al obtener opciones de formulario` (500)

**GET** `/clients/suggestions`
- Sin mensajes de error específicos (consulta corta devuelve lista vacía)

---

### Actividades del cliente
**GET** `/clients/{client}/activities`
- `No tienes permiso para este cliente` (403)
- `Error al listar actividades del cliente` (500)

**POST** `/clients/{client}/activities`
- `No tienes permiso para este cliente` (403)
- `Error de validación` (422)
- `Error al crear la actividad del cliente` (500)

**PUT/PATCH** `/clients/{client}/activities/{activity}`
- `No tienes permiso para este cliente` (403)
- `La actividad no pertenece al cliente` (403)
- `Error de validación` (422)
- `Error al actualizar la actividad del cliente` (500)

---

### Tareas del cliente
**POST** `/clients/{client}/tasks`
- `No tienes permiso para este cliente` (403)
- `Error de validación` (422)
- `Error al crear la tarea del cliente` (500)

---

### Proyectos
**GET** `/projects`
- `Error al listar proyectos del cazador` (500)

**GET** `/projects/{id}`
- `ID de proyecto inválido` (400)
- `Proyecto no encontrado` (404)
- `Error al obtener detalle del proyecto` (500)

**GET** `/projects/{id}/units`
- `ID de proyecto inválido` (400)
- `Proyecto no encontrado` (404)
- `Error al listar unidades del proyecto` (500)

---

### Reservas
**GET** `/reservations`
- `Error al listar reservas del cazador` (500)

**GET** `/reservations/{id}`
- `ID de reserva inválido` (400)
- `Reserva no encontrada` (404)
- `No tienes permiso para acceder a esta reserva` (403)
- `Error al obtener la reserva solicitada` (500)

**POST** `/reservations`
- `Error de validación` (422)
- `La unidad seleccionada no existe` (404)
- `La unidad seleccionada no está disponible` (422)
- `La unidad no pertenece al proyecto seleccionado` (422)
- Mensaje de dominio (422) desde servicio
- `Error al crear la reserva en Cazador` (500)

**POST** `/reservations/batch`
- `La lista de reservas es obligatoria` (422)

**PUT/PATCH** `/reservations/{id}`
- `ID de reserva inválido` (400)
- `Reserva no encontrada` (404)
- `No tienes permiso para actualizar esta reserva` (403)
- `Solo se pueden editar reservas con estado activa` (422)
- `Error de validación` (422)
- `Error al actualizar la reserva en Cazador` (500)

**POST** `/reservations/{id}/confirm`
- `ID de reserva inválido` (400)
- `Reserva no encontrada` (404)
- `No tienes permiso para confirmar esta reserva` (403)
- `Solo se pueden confirmar reservas con estado activa` (422)
- `Error de validación` (422)
- `Error al confirmar la reserva con comprobante` (500)

**POST** `/reservations/{id}/cancel`
- `ID de reserva inválido` (400)
- `Reserva no encontrada` (404)
- `No tienes permiso para cancelar esta reserva` (403)
- `La reserva no puede ser cancelada en su estado actual` (422)
- `Error de validación` (422)
- `Error al cancelar la reserva` (500)

**POST** `/reservations/{id}/convert-to-sale`
- `ID de reserva inválido` (400)
- `Reserva no encontrada` (404)
- `No tienes permiso para convertir esta reserva` (403)
- `Solo se pueden convertir reservas con estado confirmada` (422)
- `La unidad no puede ser vendida en su estado actual` (422)
- `Error al convertir la reserva a venta` (500)

---

### Dateros
**GET** `/dateros`
- `Usuario no autenticado` (401)
- `No tienes permiso para realizar esta acción.` (403)
- `Error al obtener los dateros` (500)

**POST** `/dateros`
- `Usuario no autenticado` (401)
- `No tienes permiso para realizar esta acción.` (403)
- `Error de validación` (422)
- `Error al registrar el datero` (500)

**GET** `/dateros/{id}`
- `Usuario no autenticado` (401)
- `No tienes permiso para realizar esta acción.` (403)
- `Datero no encontrado` (404)
- `No tienes permiso para acceder a este datero.` (403)
- `Error al obtener el datero` (500)

**PUT/PATCH** `/dateros/{id}`
- `Usuario no autenticado` (401)
- `No tienes permiso para realizar esta acción.` (403)
- `Datero no encontrado` (404)
- `No tienes permiso para acceder a este datero.` (403)
- `Error de validación` (422)
- `Error al actualizar el datero` (500)

---

### Dashboard
**GET** `/dashboard/stats`
- `Usuario no autenticado` (401)
- `Error al obtener estadisticas del dashboard` (500)

---

### Sync
**GET** `/sync?since=...`
- `El parametro since es obligatorio` (422)
- `Error al sincronizar datos` (500)

---

### Export
**GET** `/export/clients`
- `Error al exportar clientes` (500)

**GET** `/export/reservations`
- `Error al exportar reservas` (500)

**GET** `/export/sales-report`
- `Error al exportar reporte de ventas` (500)

---

## Recomendaciones de manejo en Flutter
- Mapear por `statusCode`:
  - 401: redirigir a login / refrescar token.
  - 403: mostrar alerta de permisos.
  - 404: mostrar “No encontrado”.
  - 422: mostrar errores de validación por campo.
  - 500: mostrar error genérico con opción de reintento.
- Para duplicados, usar `message` del response (ej. `Telefono registrado por "Juan Perez"`).
