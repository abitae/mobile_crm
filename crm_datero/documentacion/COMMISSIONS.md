# API Datero - Comisiones

## 📋 Descripción

Endpoints para consultar comisiones asignadas al datero autenticado. Los dateros solo pueden ver sus propias comisiones.

## 💰 Endpoints

### 1. Listar Comisiones

Obtiene una lista paginada de las comisiones asignadas al datero autenticado.

**Endpoint**: `GET /api/datero/commissions`

**URL Completa**: `https://tu-dominio.com/api/datero/commissions`

**Autenticación**: Requerida (Bearer Token)

#### Parámetros de Consulta

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `page` | integer | No | Número de página (default: 1) |
| `per_page` | integer | No | Elementos por página (default: 15, máximo: 100) |
| `status` | string | No | Filtrar por estado (pendiente, aprobada, pagada, cancelada) |
| `commission_type` | string | No | Filtrar por tipo de comisión |
| `start_date` | date | No | Fecha de inicio (formato: YYYY-MM-DD) |
| `end_date` | date | No | Fecha de fin (formato: YYYY-MM-DD) |

> **Nota**: `start_date` y `end_date` deben usarse juntos para filtrar por rango de fechas.

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
# Listar todas las comisiones
curl -X GET "https://tu-dominio.com/api/datero/commissions" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# Filtrar por estado
curl -X GET "https://tu-dominio.com/api/datero/commissions?status=pagada" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# Filtrar por rango de fechas
curl -X GET "https://tu-dominio.com/api/datero/commissions?start_date=2024-01-01&end_date=2024-01-31" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# Combinar filtros
curl -X GET "https://tu-dominio.com/api/datero/commissions?status=aprobada&per_page=20" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Comisiones obtenidas exitosamente",
  "data": {
    "commissions": [
      {
        "id": 1,
        "project": {
          "id": 5,
          "name": "Residencial Los Olivos"
        },
        "unit": {
          "id": 12,
          "unit_number": "A-101"
        },
        "opportunity": {
          "id": 8,
          "client_name": "María González"
        },
        "commission_type": "venta",
        "base_amount": 150000.00,
        "commission_percentage": 3.5,
        "commission_amount": 5250.00,
        "bonus_amount": 500.00,
        "total_commission": 5750.00,
        "status": "pagada",
        "payment_date": "2024-01-20",
        "payment_method": "transferencia",
        "payment_reference": "TRF-2024-001",
        "notes": "Pago completado",
        "approved_at": "2024-01-15 10:30:00",
        "paid_at": "2024-01-20 14:15:00",
        "created_at": "2024-01-10 09:00:00",
        "updated_at": "2024-01-20 14:15:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 15,
      "total": 25,
      "last_page": 2,
      "from": 1,
      "to": 15
    }
  }
}
```

---

### 2. Obtener Comisión Específica

Obtiene los detalles de una comisión específica asignada al datero.

**Endpoint**: `GET /api/datero/commissions/{id}`

**URL Completa**: `https://tu-dominio.com/api/datero/commissions/1`

**Autenticación**: Requerida (Bearer Token)

#### Parámetros de Ruta

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `id` | integer | Sí | ID de la comisión |

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/datero/commissions/1" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Comisión obtenida exitosamente",
  "data": {
    "commission": {
      "id": 1,
      "project": {
        "id": 5,
        "name": "Residencial Los Olivos"
      },
      "unit": {
        "id": 12,
        "unit_number": "A-101"
      },
      "opportunity": {
        "id": 8,
        "client_name": "María González"
      },
      "commission_type": "venta",
      "base_amount": 150000.00,
      "commission_percentage": 3.5,
      "commission_amount": 5250.00,
      "bonus_amount": 500.00,
      "total_commission": 5750.00,
      "status": "pagada",
      "payment_date": "2024-01-20",
      "payment_method": "transferencia",
      "payment_reference": "TRF-2024-001",
      "notes": "Pago completado",
      "approved_at": "2024-01-15 10:30:00",
      "paid_at": "2024-01-20 14:15:00",
      "created_at": "2024-01-10 09:00:00",
      "updated_at": "2024-01-20 14:15:00"
    }
  }
}
```

#### Respuesta de Error (403)

```json
{
  "success": false,
  "message": "No tienes permiso para acceder a esta comisión"
}
```

#### Respuesta de Error (404)

```json
{
  "success": false,
  "message": "Comisión no encontrada"
}
```

---

### 3. Obtener Estadísticas de Comisiones

Obtiene estadísticas agregadas de las comisiones del datero autenticado.

**Endpoint**: `GET /api/datero/commissions/stats`

**URL Completa**: `https://tu-dominio.com/api/datero/commissions/stats`

**Autenticación**: Requerida (Bearer Token)

#### Headers

```
Authorization: Bearer {token}
```

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/datero/commissions/stats" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Estadísticas obtenidas exitosamente",
  "data": {
    "stats": {
      "total": 25,
      "pendiente": 5,
      "aprobada": 8,
      "pagada": 10,
      "cancelada": 2,
      "total_pagado": 57500.00,
      "total_pendiente": 12500.00,
      "total_mes_actual": 15000.00,
      "total_anio_actual": 70000.00
    }
  }
}
```

#### Descripción de Campos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `total` | integer | Total de comisiones |
| `pendiente` | integer | Comisiones pendientes |
| `aprobada` | integer | Comisiones aprobadas |
| `pagada` | integer | Comisiones pagadas |
| `cancelada` | integer | Comisiones canceladas |
| `total_pagado` | float | Suma total de comisiones pagadas |
| `total_pendiente` | float | Suma total de comisiones pendientes |
| `total_mes_actual` | float | Suma total de comisiones del mes actual |
| `total_anio_actual` | float | Suma total de comisiones del año actual |

---

## 📊 Estados de Comisión

Los estados posibles de una comisión son:

- **pendiente**: Comisión pendiente de aprobación
- **aprobada**: Comisión aprobada, pendiente de pago
- **pagada**: Comisión pagada
- **cancelada**: Comisión cancelada

## 🔒 Permisos y Restricciones

- Los dateros **solo pueden ver** sus propias comisiones
- No pueden crear, editar o eliminar comisiones
- Las comisiones son asignadas automáticamente por el sistema

## 📝 Notas Importantes

1. **Filtrado por fecha**: Para usar el filtro de fechas, debes proporcionar tanto `start_date` como `end_date`
2. **Paginación**: Por defecto se muestran 15 comisiones por página, máximo 100
3. **Ordenamiento**: Las comisiones se ordenan por fecha de creación descendente (más recientes primero)
4. **Estadísticas**: Las estadísticas se calculan en tiempo real basándose en las comisiones del datero autenticado

