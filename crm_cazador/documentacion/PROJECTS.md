# API Cazador - Proyectos

## 📋 Descripción

Endpoints para consultar proyectos y unidades disponibles. Los proyectos están enfocados en **lotes** y solo se muestran unidades con estado **disponible**.

## 🏗️ Endpoints

### 1. Listar Proyectos

Obtiene una lista paginada de todos los proyectos disponibles.

**Endpoint**: `GET /api/cazador/projects`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Parámetros de Query

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `per_page` | integer | No | Elementos por página (máximo 100, por defecto 15) |
| `page` | integer | No | Número de página (por defecto 1) |
| `search` | string | No | Búsqueda en nombre, descripción, dirección, distrito, provincia |
| `project_type` | string | No | Tipo de proyecto |
| `lote_type` | string | No | Tipo de lote (normal, express) |
| `stage` | string | No | Etapa del proyecto (preventa, lanzamiento, venta_activa, cierre) |
| `legal_status` | string | No | Estado legal |
| `status` | string | No | Estado del proyecto (activo, inactivo, suspendido, finalizado) |
| `district` | string | No | Distrito |
| `province` | string | No | Provincia |
| `region` | string | No | Región |
| `has_available_units` | boolean | No | Solo proyectos con unidades disponibles |

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/cazador/projects?per_page=20&stage=venta_activa&has_available_units=true" \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Proyectos obtenidos exitosamente",
  "data": {
    "projects": [
      {
        "id": 1,
        "name": "Proyecto Los Olivos",
        "description": "Lotes residenciales en zona premium",
        "project_type": "lotes",
        "is_published": true,
        "lote_type": "normal",
        "stage": "venta_activa",
        "legal_status": "con_titulo",
        "estado_legal": "Titulo de propiedad",
        "tipo_proyecto": "propio",
        "tipo_financiamiento": "contado",
        "banco": "Banco de Crédito",
        "tipo_cuenta": "cuenta corriente",
        "cuenta_bancaria": "1234567890",
        "address": "Av. Principal 123",
        "district": "Los Olivos",
        "province": "Lima",
        "region": "Lima",
        "country": "Perú",
        "ubicacion": "https://maps.google.com/?q=-11.9699,-77.0078",
        "full_address": "Av. Principal 123, Los Olivos, Lima, Lima, Perú",
        "coordinates": {
          "lat": -11.9699,
          "lng": -77.0078
        },
        "total_units": 100,
        "available_units": 45,
        "reserved_units": 20,
        "sold_units": 35,
        "blocked_units": 0,
        "progress_percentage": 55.0,
        "start_date": "2024-01-01",
        "end_date": "2025-12-31",
        "delivery_date": "2025-06-30",
        "status": "activo",
        "path_image_portada": "/images/projects/1/portada.jpg",
        "path_video_portada": null,
        "path_images": ["/images/projects/1/img1.jpg"],
        "path_videos": [],
        "path_documents": ["/documents/projects/1/plano.pdf"],
        "advisors": [
          {
            "id": 2,
            "name": "María García",
            "email": "maria@example.com",
            "is_primary": true
          }
        ],
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-15 14:30:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 50,
      "last_page": 3,
      "from": 1,
      "to": 20
    }
  }
}
```

---

### 2. Obtener Proyecto Específico

Obtiene los detalles completos de un proyecto, incluyendo unidades disponibles paginadas.

**Endpoint**: `GET /api/cazador/projects/{id}`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

#### Parámetros de Query

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `units_per_page` | integer | No | Unidades por página (máximo 100, por defecto 15) |
| `include_units` | boolean | No | Incluir unidades en la respuesta (por defecto true) |

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/cazador/projects/1?units_per_page=20" \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Proyecto obtenido exitosamente",
  "data": {
    "project": {
      "id": 1,
      "name": "Proyecto Los Olivos",
      "description": "Lotes residenciales en zona premium",
      // ... todos los campos del proyecto ...
      "units": [
        {
          "id": 1,
          "project_id": 1,
          "unit_manzana": "A",
          "unit_number": "Lote-001",
          "unit_type": "lote",
          "floor": null,
          "tower": null,
          "block": null,
          "area": 300.50,
          "bedrooms": 0,
          "bathrooms": 0,
          "parking_spaces": 2,
          "storage_rooms": 1,
          "balcony_area": 0.0,
          "terrace_area": 0.0,
          "garden_area": 150.25,
          "total_area": 450.75,
          "status": "disponible",
          "base_price": 50000.00,
          "total_price": 15025000.00,
          "discount_percentage": 5.0,
          "discount_amount": 751250.00,
          "final_price": 14273750.00,
          "price_per_square_meter": 31666.67,
          "commission_percentage": 3.0,
          "commission_amount": 428212.50,
          "blocked_until": null,
          "blocked_reason": null,
          "is_blocked": false,
          "is_available": true,
          "full_identifier": "Proyecto Los Olivos - Unidad Lote-001",
          "notes": null,
          "created_at": "2024-01-01 10:00:00",
          "updated_at": "2024-01-01 10:00:00"
        }
      ],
      "units_pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 45,
        "last_page": 3,
        "from": 1,
        "to": 20
      }
    }
  }
}
```

#### Errores Posibles

- **400**: ID de proyecto inválido
- **401**: No autenticado
- **404**: Proyecto no encontrado
- **500**: Error del servidor

---

### 3. Obtener Unidades de un Proyecto

Obtiene una lista paginada de unidades disponibles de un proyecto específico.

**Endpoint**: `GET /api/cazador/projects/{id}/units`

**Autenticación**: Requerida (JWT)

**Rate Limit**: 60 requests por minuto

> ⚠️ **Importante**: Este endpoint solo devuelve unidades con estado **disponible**. Las unidades se ordenan primero por **manzana** y luego por **número de unidad**.

#### Parámetros de Query

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `per_page` | integer | No | Elementos por página (máximo 100, por defecto 15) |
| `page` | integer | No | Número de página (por defecto 1) |

#### Ejemplo de Solicitud

```bash
curl -X GET "https://tu-dominio.com/api/cazador/projects/1/units?per_page=30" \
  -H "Authorization: Bearer {token}"
```

#### Respuesta Exitosa (200)

```json
{
  "success": true,
  "message": "Unidades obtenidas exitosamente",
  "data": {
    "project": {
      "id": 1,
      "name": "Proyecto Los Olivos"
    },
    "units": [
      {
        "id": 1,
        "project_id": 1,
        "unit_manzana": "A",
        "unit_number": "Lote-001",
        "unit_type": "lote",
        "area": 300.50,
        "total_area": 450.75,
        "status": "disponible",
        "final_price": 14273750.00,
        "price_per_square_meter": 31666.67,
        "is_available": true,
        "full_identifier": "Proyecto Los Olivos - Unidad Lote-001",
        // ... resto de campos ...
      },
      {
        "id": 2,
        "project_id": 1,
        "unit_manzana": "A",
        "unit_number": "Lote-002",
        // ... resto de campos ...
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 30,
      "total": 45,
      "last_page": 2,
      "from": 1,
      "to": 30
    }
  }
}
```

#### Errores Posibles

- **400**: ID de proyecto inválido
- **401**: No autenticado
- **404**: Proyecto no encontrado
- **500**: Error del servidor

---

## 📊 Estructura de Datos

### Proyecto

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | integer | ID del proyecto |
| `name` | string | Nombre del proyecto |
| `description` | string | Descripción |
| `project_type` | string | Tipo de proyecto |
| `lote_type` | string | Tipo de lote (normal, express) |
| `stage` | string | Etapa (preventa, lanzamiento, venta_activa, cierre) |
| `legal_status` | string | Estado legal |
| `address` | string | Dirección |
| `district` | string | Distrito |
| `province` | string | Provincia |
| `region` | string | Región |
| `total_units` | integer | Total de unidades |
| `available_units` | integer | Unidades disponibles |
| `reserved_units` | integer | Unidades reservadas |
| `sold_units` | integer | Unidades vendidas |
| `progress_percentage` | float | Porcentaje de progreso |
| `advisors` | array | Asesores asignados |

### Unidad

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | integer | ID de la unidad |
| `project_id` | integer | ID del proyecto |
| `unit_manzana` | string | Manzana |
| `unit_number` | string | Número de unidad |
| `unit_type` | string | Tipo (siempre "lote") |
| `area` | float | Área en m² |
| `total_area` | float | Área total |
| `status` | string | Estado (siempre "disponible") |
| `final_price` | float | Precio final |
| `price_per_square_meter` | float | Precio por m² |
| `is_available` | boolean | Disponible |
| `full_identifier` | string | Identificador completo |

---

## 🔍 Filtros Disponibles

### Filtros de Proyecto

- **Búsqueda de texto**: Busca en nombre, descripción, dirección, distrito y provincia
- **Tipo de proyecto**: Filtra por tipo de proyecto
- **Tipo de lote**: Filtra por tipo de lote (normal, express)
- **Etapa**: Filtra por etapa del proyecto
- **Estado legal**: Filtra por estado legal
- **Estado**: Filtra por estado del proyecto
- **Ubicación**: Filtra por distrito, provincia o región
- **Unidades disponibles**: Solo proyectos con unidades disponibles

---

## 📝 Notas Importantes

1. **Solo unidades disponibles**: Todos los endpoints de unidades solo devuelven unidades con estado "disponible"
2. **Ordenamiento**: Las unidades se ordenan primero por manzana (ascendente) y luego por número de unidad (ascendente)
3. **Paginación**: Todos los endpoints de listado utilizan paginación
4. **Límite de paginación**: El máximo de elementos por página es 100
5. **Proyectos de lotes**: Esta API está enfocada en proyectos de lotes

---

**Última actualización**: 2024-01-01

