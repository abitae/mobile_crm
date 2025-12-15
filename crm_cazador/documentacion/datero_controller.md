# Documentación API - DateroController (Cazador)

## Descripción General

El `DateroController` es un controlador API RESTful que permite a los usuarios con rol **Cazador**, **Líder** o **Administrador** gestionar usuarios con rol **Datero** (captadores de datos) que están asociados a ellos mediante el campo `lider_id`.

### Características Principales

- ✅ **Autenticación requerida**: Todas las rutas requieren JWT válido
- ✅ **Control de permisos**: Solo usuarios con acceso al API Cazador pueden usar estos endpoints
- ✅ **Aislamiento de datos**: Cada cazador solo puede gestionar sus propios dateros
- ✅ **Validación robusta**: Validación completa de datos de entrada
- ✅ **Sanitización**: Limpieza automática de datos sensibles
- ✅ **Manejo de errores**: Logging detallado y respuestas consistentes

---

## Base URL

```
https://tu-dominio.com/api/cazador/dateros
```

---

## Autenticación

Todas las peticiones requieren un token JWT en el header:

```
Authorization: Bearer {token}
```

---

## Endpoints

### 1. Listar Dateros

Obtiene una lista paginada de dateros asociados al cazador autenticado.

**Endpoint:** `GET /api/cazador/dateros`

**Parámetros Query (opcionales):**

| Parámetro | Tipo | Descripción | Valores |
|-----------|------|-------------|---------|
| `per_page` | integer | Elementos por página | 1-100 (default: 15) |
| `search` | string | Búsqueda por nombre, email, teléfono o DNI | Texto libre |
| `is_active` | boolean | Filtrar por estado activo | `true` o `false` |

**Ejemplo de petición:**

```dart
// Flutter
final response = await http.get(
  Uri.parse('$baseUrl/api/cazador/dateros?per_page=20&search=juan&is_active=true'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

**Respuesta exitosa (200 OK):**

```json
{
  "success": true,
  "message": "Dateros obtenidos exitosamente",
  "data": {
    "dateros": [
      {
        "id": 10,
        "name": "Juan Pérez",
        "email": "juan@example.com",
        "phone": "999999999",
        "dni": "12345678",
        "ocupacion": "Vendedor",
        "role": "Datero",
        "is_active": true,
        "banco": "BCP",
        "cuenta_bancaria": "123-4567890-0-12",
        "cci_bancaria": "00212345678901234567",
        "lider": {
          "id": 3,
          "name": "Líder Cazador",
          "email": "lider@example.com"
        }
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 1,
      "last_page": 1,
      "from": 1,
      "to": 1
    }
  }
}
```

---

### 2. Registrar Datero

Crea un nuevo usuario con rol Datero asociado al cazador autenticado.

**Endpoint:** `POST /api/cazador/dateros`

**Body (JSON):**

| Campo | Tipo | Requerido | Descripción | Validación |
|-------|------|-----------|-------------|------------|
| `name` | string | ✅ Sí | Nombre completo | Máx. 255 caracteres |
| `email` | string | ✅ Sí | Email único | Email válido, único en BD |
| `phone` | string | ✅ Sí | Teléfono | Máx. 20 caracteres |
| `dni` | string | ✅ Sí | DNI | Exactamente 8 dígitos numéricos, único |
| `pin` | string | ✅ Sí | PIN de acceso | Exactamente 6 dígitos numéricos |
| `ocupacion` | string | ❌ No | Ocupación del datero | Máx. 255 caracteres |
| `banco` | string | ❌ No | Nombre del banco | Máx. 255 caracteres |
| `cuenta_bancaria` | string | ❌ No | Número de cuenta | Máx. 255 caracteres |
| `cci_bancaria` | string | ❌ No | Código CCI | Máx. 255 caracteres |

**Ejemplo de petición:**

```dart
// Flutter
final response = await http.post(
  Uri.parse('$baseUrl/api/cazador/dateros'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'name': 'Juan Pérez',
    'email': 'juan@example.com',
    'phone': '999999999',
    'dni': '12345678',
    'pin': '123456',
    'ocupacion': 'Vendedor',
    'banco': 'BCP',
    'cuenta_bancaria': '123-4567890-0-12',
    'cci_bancaria': '00212345678901234567',
  }),
);
```

**Respuesta exitosa (201 Created):**

```json
{
  "success": true,
  "message": "Datero registrado exitosamente.",
  "data": {
    "user": {
      "id": 10,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "phone": "999999999",
      "dni": "12345678",
      "ocupacion": "Vendedor",
      "role": "datero",
      "is_active": true,
      "lider": {
        "id": 3,
        "name": "Líder Cazador",
        "email": "lider@example.com"
      }
    }
  }
}
```

**Errores comunes:**

- **422 Unprocessable Entity**: Validación fallida
  ```json
  {
    "success": false,
    "message": "Error de validación",
    "errors": {
      "dni": ["Este DNI ya está registrado."],
      "email": ["Este email ya está registrado."]
    }
  }
  ```

---

### 3. Ver Detalle de Datero

Obtiene la información completa de un datero específico.

**Endpoint:** `GET /api/cazador/dateros/{id}`

**Parámetros URL:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | integer | ID del datero |

**Ejemplo de petición:**

```dart
// Flutter
final response = await http.get(
  Uri.parse('$baseUrl/api/cazador/dateros/10'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

**Respuesta exitosa (200 OK):**

```json
{
  "success": true,
  "message": "Datero obtenido exitosamente",
  "data": {
    "user": {
      "id": 10,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "phone": "999999999",
      "dni": "12345678",
      "ocupacion": "Vendedor",
      "role": "datero",
      "is_active": true,
      "banco": "BCP",
      "cuenta_bancaria": "123-4567890-0-12",
      "cci_bancaria": "00212345678901234567",
      "lider": {
        "id": 3,
        "name": "Líder Cazador",
        "email": "lider@example.com"
      }
    }
  }
}
```

**Errores comunes:**

- **404 Not Found**: Datero no encontrado
- **403 Forbidden**: El datero no pertenece al cazador autenticado

---

### 4. Actualizar Datero

Actualiza los datos de un datero existente. Solo se actualizan los campos enviados.

**Endpoint:** `PUT /api/cazador/dateros/{id}` o `PATCH /api/cazador/dateros/{id}`

**Parámetros URL:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | integer | ID del datero |

**Body (JSON) - Todos los campos son opcionales:**

| Campo | Tipo | Descripción | Validación |
|-------|------|-------------|------------|
| `name` | string | Nombre completo | Máx. 255 caracteres |
| `email` | string | Email | Email válido, único (excepto el mismo usuario) |
| `phone` | string | Teléfono | Máx. 20 caracteres |
| `dni` | string | DNI | 8 dígitos numéricos, único (excepto el mismo usuario) |
| `pin` | string | Nuevo PIN | 6 dígitos numéricos |
| `ocupacion` | string | Ocupación | Máx. 255 caracteres |
| `banco` | string | Nombre del banco | Máx. 255 caracteres |
| `cuenta_bancaria` | string | Número de cuenta | Máx. 255 caracteres |
| `cci_bancaria` | string | Código CCI | Máx. 255 caracteres |
| `is_active` | boolean | Estado activo | `true` o `false` |

**Ejemplo de petición:**

```dart
// Flutter - Actualizar solo nombre y ocupación
final response = await http.patch(
  Uri.parse('$baseUrl/api/cazador/dateros/10'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'name': 'Juan Pérez Actualizado',
    'ocupacion': 'Supervisor',
  }),
);
```

**Ejemplo - Cambiar PIN:**

```dart
// Flutter - Cambiar PIN del datero
final response = await http.patch(
  Uri.parse('$baseUrl/api/cazador/dateros/10'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'pin': '654321',
  }),
);
```

**Respuesta exitosa (200 OK):**

```json
{
  "success": true,
  "message": "Datero actualizado exitosamente",
  "data": {
    "user": {
      "id": 10,
      "name": "Juan Pérez Actualizado",
      "email": "juan@example.com",
      "phone": "999999999",
      "dni": "12345678",
      "ocupacion": "Supervisor",
      "role": "datero",
      "is_active": true,
      "banco": "BCP",
      "cuenta_bancaria": "123-4567890-0-12",
      "cci_bancaria": "00212345678901234567",
      "lider": {
        "id": 3,
        "name": "Líder Cazador",
        "email": "lider@example.com"
      }
    }
  }
}
```

**Errores comunes:**

- **404 Not Found**: Datero no encontrado
- **403 Forbidden**: El datero no pertenece al cazador autenticado
- **422 Unprocessable Entity**: Validación fallida

---

## Estructura de Datos

### Objeto User (Datero)

```typescript
interface Datero {
  id: number;
  name: string;
  email: string;
  phone: string;
  dni: string; // 8 dígitos
  ocupacion: string | null;
  role: "Datero";
  is_active: boolean;
  banco: string | null;
  cuenta_bancaria: string | null;
  cci_bancaria: string | null;
  lider: {
    id: number;
    name: string;
    email: string;
  };
}
```

### Objeto Pagination

```typescript
interface Pagination {
  current_page: number;
  per_page: number;
  total: number;
  last_page: number;
  from: number | null;
  to: number | null;
}
```

---

## Códigos de Estado HTTP

| Código | Descripción |
|--------|-------------|
| `200` | OK - Operación exitosa |
| `201` | Created - Recurso creado exitosamente |
| `400` | Bad Request - Solicitud mal formada |
| `401` | Unauthorized - No autenticado |
| `403` | Forbidden - Sin permisos o datero no pertenece al cazador |
| `404` | Not Found - Datero no encontrado |
| `422` | Unprocessable Entity - Error de validación |
| `500` | Internal Server Error - Error del servidor |

---

## Ejemplos de Implementación Flutter

### Servicio Completo

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DateroService {
  final String baseUrl;
  final String token;

  DateroService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // Listar dateros
  Future<Map<String, dynamic>> listDateros({
    int perPage = 15,
    String? search,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage.toString(),
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final uri = Uri.parse('$baseUrl/api/cazador/dateros')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener dateros: ${response.statusCode}');
    }
  }

  // Registrar datero
  Future<Map<String, dynamic>> registerDatero({
    required String name,
    required String email,
    required String phone,
    required String dni,
    required String pin,
    String? ocupacion,
    String? banco,
    String? cuentaBancaria,
    String? cciBancaria,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'dni': dni,
      'pin': pin,
      if (ocupacion != null) 'ocupacion': ocupacion,
      if (banco != null) 'banco': banco,
      if (cuentaBancaria != null) 'cuenta_bancaria': cuentaBancaria,
      if (cciBancaria != null) 'cci_bancaria': cciBancaria,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/cazador/dateros'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al registrar datero');
    }
  }

  // Ver detalle
  Future<Map<String, dynamic>> getDatero(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cazador/dateros/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datero: ${response.statusCode}');
    }
  }

  // Actualizar datero
  Future<Map<String, dynamic>> updateDatero(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/cazador/dateros/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al actualizar datero');
    }
  }
}
```

### Uso del Servicio

```dart
// Inicializar servicio
final dateroService = DateroService(
  baseUrl: 'https://tu-dominio.com',
  token: 'tu-jwt-token',
);

// Listar dateros
try {
  final result = await dateroService.listDateros(
    perPage: 20,
    search: 'juan',
    isActive: true,
  );
  
  final dateros = result['data']['dateros'] as List;
  final pagination = result['data']['pagination'];
  
  print('Total dateros: ${pagination['total']}');
} catch (e) {
  print('Error: $e');
}

// Registrar nuevo datero
try {
  final result = await dateroService.registerDatero(
    name: 'Juan Pérez',
    email: 'juan@example.com',
    phone: '999999999',
    dni: '12345678',
    pin: '123456',
    ocupacion: 'Vendedor',
  );
  
  final user = result['data']['user'];
  print('Datero creado: ${user['name']}');
} catch (e) {
  print('Error: $e');
}

// Actualizar datero
try {
  final result = await dateroService.updateDatero(10, {
    'name': 'Juan Pérez Actualizado',
    'ocupacion': 'Supervisor',
  });
  
  print('Datero actualizado exitosamente');
} catch (e) {
  print('Error: $e');
}
```

---

## Notas Importantes

### Seguridad

1. **PIN**: El PIN se almacena hasheado y nunca se devuelve en las respuestas
2. **Propiedad**: Cada cazador solo puede gestionar dateros cuyo `lider_id` coincida con su ID
3. **Validación**: El DNI debe tener exactamente 8 dígitos numéricos
4. **Validación**: El PIN debe tener exactamente 6 dígitos numéricos

### Comportamiento Especial

- **lider_id**: Se asigna automáticamente al ID del usuario autenticado al crear un datero
- **is_active**: Se establece automáticamente en `true` al crear un datero
- **password**: Se establece automáticamente igual al PIN (para compatibilidad)
- **Actualización parcial**: En `update`, solo se actualizan los campos enviados

### Mejoras del Controlador

El controlador ha sido refactorizado con las siguientes mejoras:

- ✅ Métodos helper para reducir duplicación de código
- ✅ Validaciones centralizadas y reutilizables
- ✅ Sanitización automática de datos
- ✅ Formateo consistente de respuestas
- ✅ Manejo de errores mejorado con logging detallado
- ✅ Código más mantenible y testeable

---

## Versión

**Última actualización:** Diciembre 2024  
**Versión del controlador:** 2.0 (Refactorizado)

