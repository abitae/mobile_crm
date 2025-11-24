# API REST para Aplicación Móvil - Dateros

API REST optimizada para aplicaciones móviles Flutter, que permite a usuarios con rol **datero** gestionar clientes desde dispositivos móviles utilizando autenticación JWT (JSON Web Tokens).

## 🚀 Características

- ✅ Autenticación JWT segura
- ✅ Rate limiting para prevenir abusos
- ✅ Respuestas estandarizadas y consistentes
- ✅ Optimizada para consumo móvil
- ✅ Paginación eficiente
- ✅ Filtros y búsqueda avanzada
- ✅ Validación robusta de datos

## 📋 Tabla de Contenidos

1. [Configuración Base](#configuración-base)
2. [Autenticación](#autenticación)
3. [Gestión de Clientes](#gestión-de-clientes)
4. [Modelos de Datos](#modelos-de-datos)
5. [Manejo de Errores](#manejo-de-errores)
6. [Implementación Flutter](#implementación-flutter)
7. [Rate Limiting](#rate-limiting)
8. [Mejores Prácticas](#mejores-prácticas)

---

## 🔧 Configuración Base

### Base URL

```
https://crm_inmobiliaria.test/api
```

### Headers Comunes

Todas las peticiones requieren:

```
Content-Type: application/json
Accept: application/json
```

Para peticiones autenticadas, agregar:

```
Authorization: Bearer {token}
```

### Formato de Respuesta Estándar

Todas las respuestas siguen este formato:

**Éxito:**
```json
{
    "success": true,
    "message": "Mensaje descriptivo",
    "data": { /* datos de la respuesta */ }
}
```

**Error:**
```json
{
    "success": false,
    "message": "Mensaje de error",
    "errors": { /* detalles de errores (opcional) */ }
}
```

---

## 🔐 Autenticación

### 1. Login (POST)

Iniciar sesión y obtener token JWT.

**Endpoint:** `POST /auth/login`

**Rate Limit:** 5 solicitudes por minuto

**Request:**
```json
{
    "email": "datero@example.com",
    "password": "password123"
}
```

**Response 200 (Success):**
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
            "name": "Pedro Ramírez",
            "email": "pedro.ramirez@crm.com",
            "phone": "987654321",
            "role": "datero"
        }
    }
}
```

**Response 422 (Validación):**
```json
{
    "success": false,
    "message": "Error de validación",
    "errors": {
        "email": ["El email es obligatorio."],
        "password": ["La contraseña es obligatoria."]
    }
}
```

**Response 401 (Credenciales inválidas):**
```json
{
    "success": false,
    "message": "Credenciales inválidas"
}
```

**Response 403 (No es datero):**
```json
{
    "success": false,
    "message": "Acceso denegado. Solo usuarios con rol datero pueden acceder."
}
```

**Response 403 (Cuenta inactiva):**
```json
{
    "success": false,
    "message": "Tu cuenta está desactivada. Contacta al administrador."
}
```

---

### 2. Obtener Usuario Autenticado (GET)

Obtener información del usuario autenticado.

**Endpoint:** `GET /auth/me`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Pedro Ramírez",
        "email": "pedro.ramirez@crm.com",
        "phone": "987654321",
        "role": "datero",
        "is_active": true
    }
}
```

**Response 401:**
```json
{
    "success": false,
    "message": "Usuario no autenticado"
}
```

---

### 3. Logout (POST)

Cerrar sesión e invalidar el token.

**Endpoint:** `POST /auth/logout`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Sesión cerrada exitosamente"
}
```

---

### 4. Refrescar Token (POST)

Obtener un nuevo token JWT con tiempo de vida extendido.

**Endpoint:** `POST /auth/refresh`

**Headers Requeridos:**
```
Authorization: Bearer {token}
```

**Response 200:**
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

**Response 401:**
```json
{
    "success": false,
    "message": "Token inválido o expirado"
}
```

---

## 👥 Gestión de Clientes

### Restricciones

- ✅ Solo usuarios con rol **datero** pueden acceder
- ✅ Solo pueden ver/editar clientes que **ellos crearon** (`created_by = user_id`)
- ✅ Acceso denegado (403) si intentas acceder a un cliente de otro datero
- ✅ El `document_number` debe ser único en el sistema

### 1. Listar Clientes (GET)

Obtener lista paginada de clientes del datero autenticado.

**Endpoint:** `GET /clients`

**Rate Limit:** 60 solicitudes por minuto

**Query Parameters (todos opcionales):**

| Parámetro | Tipo | Descripción | Valores |
|-----------|------|-------------|---------|
| `per_page` | integer | Elementos por página | 1-100 (default: 15) |
| `search` | string | Búsqueda en nombre, teléfono o documento | Cualquier texto |
| `status` | string | Filtrar por estado | Ver [Estados](#estados) |
| `type` | string | Filtrar por tipo de cliente | Ver [Tipos](#tipos-de-cliente) |
| `source` | string | Filtrar por origen | Ver [Orígenes](#orígenes) |

**Ejemplo de Request:**
```
GET /clients?per_page=20&search=Juan&status=nuevo&type=comprador
```

**Response 200:**
```json
{
    "success": true,
    "message": "Clientes obtenidos exitosamente",
    "data": {
        "clients": [
            {
                "id": 1,
                "name": "Juan Pérez",
                "phone": "987654321",
                "document_type": "DNI",
                "document_number": "12345678",
                "address": "Av. Principal 123",
                "birth_date": "1990-01-15",
                "client_type": "comprador",
                "source": "redes_sociales",
                "status": "nuevo",
                "score": 50,
                "notes": "Cliente interesado en departamentos",
                "assigned_advisor": {
                    "id": 5,
                    "name": "Ana Martínez",
                    "email": "ana.martinez@crm.com"
                },
                "created_at": "2024-01-15 10:30:00",
                "updated_at": "2024-01-15 10:30:00"
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

### 2. Ver Cliente Específico (GET)

Obtener información detallada de un cliente.

**Endpoint:** `GET /clients/{id}`

**Response 200:**
```json
{
    "success": true,
    "message": "Cliente obtenido exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "Juan Pérez",
            "phone": "987654321",
            "document_type": "DNI",
            "document_number": "12345678",
            "address": "Av. Principal 123",
            "birth_date": "1990-01-15",
            "client_type": "comprador",
            "source": "redes_sociales",
            "status": "nuevo",
            "score": 50,
            "notes": "Cliente interesado en departamentos",
            "assigned_advisor": {
                "id": 5,
                "name": "Ana Martínez",
                "email": "ana.martinez@crm.com"
            },
            "opportunities_count": 0,
            "activities_count": 2,
            "tasks_count": 1,
            "created_at": "2024-01-15 10:30:00",
            "updated_at": "2024-01-15 10:30:00"
        }
    }
}
```

**Response 404:**
```json
{
    "success": false,
    "message": "Cliente no encontrado"
}
```

**Response 403:**
```json
{
    "success": false,
    "message": "No tienes permiso para acceder a este cliente"
}
```

---

### 3. Crear Cliente (POST)

Crear un nuevo cliente.

**Endpoint:** `POST /clients`

**Request Body:**

```json
{
    "name": "Juan Pérez",
    "phone": "987654321",
    "document_type": "DNI",
    "document_number": "12345678",
    "address": "Av. Principal 123",
    "birth_date": "1990-01-15",
    "client_type": "comprador",
    "source": "redes_sociales",
    "status": "nuevo",
    "score": 50,
    "notes": "Cliente interesado en departamentos",
    "assigned_advisor_id": 5
}
```

**Campos Requeridos:**

| Campo | Tipo | Validación | Descripción |
|-------|------|------------|-------------|
| `name` | string | required, max:255 | Nombre completo |
| `document_type` | enum | required | DNI, RUC, CE, PASAPORTE |
| `document_number` | string | required, max:20, unique | Número de documento |
| `client_type` | enum | required | Ver [Tipos](#tipos-de-cliente) |
| `source` | enum | required | Ver [Orígenes](#orígenes) |
| `status` | enum | required | Ver [Estados](#estados) |
| `score` | integer | required, min:0, max:100 | Puntuación del lead |

**Campos Opcionales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `phone` | string | Teléfono (max: 20) |
| `address` | string | Dirección (max: 500) |
| `birth_date` | date | Fecha nacimiento (YYYY-MM-DD) |
| `notes` | string | Notas adicionales |
| `assigned_advisor_id` | integer | ID del asesor (debe existir) |

**Valores por Defecto:**

- `status`: `"nuevo"` (si no se proporciona)
- `score`: `0` (si no se proporciona)

**Response 201:**
```json
{
    "success": true,
    "message": "Cliente creado exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "Juan Pérez",
            "phone": "987654321",
            "document_type": "DNI",
            "document_number": "12345678",
            "address": "Av. Principal 123",
            "birth_date": "1990-01-15",
            "client_type": "comprador",
            "source": "redes_sociales",
            "status": "nuevo",
            "score": 50,
            "notes": "Cliente interesado en departamentos",
            "assigned_advisor": {
                "id": 5,
                "name": "Ana Martínez",
                "email": "ana.martinez@crm.com"
            },
            "created_at": "2024-01-15 10:30:00",
            "updated_at": "2024-01-15 10:30:00"
        }
    }
}
```

**Response 422 (Validación):**
```json
{
    "success": false,
    "message": "Error de validación",
    "errors": {
        "name": ["El nombre es obligatorio."],
        "document_number": ["El número de documento ya está registrado."]
    }
}
```

---

### 4. Actualizar Cliente (PUT/PATCH)

Actualizar un cliente existente.

**Endpoint:** `PUT /clients/{id}` o `PATCH /clients/{id}`

**Request Body:** (Todos los campos son opcionales en PATCH, required si se envía en PUT)

```json
{
    "name": "Juan Pérez García",
    "phone": "987654322",
    "status": "contacto_inicial",
    "score": 75,
    "notes": "Cliente ha mostrado interés en visita"
}
```

**Response 200:**
```json
{
    "success": true,
    "message": "Cliente actualizado exitosamente",
    "data": {
        "client": {
            "id": 1,
            "name": "Juan Pérez García",
            "phone": "987654322",
            "document_type": "DNI",
            "document_number": "12345678",
            "address": "Av. Principal 123",
            "birth_date": "1990-01-15",
            "client_type": "comprador",
            "source": "redes_sociales",
            "status": "contacto_inicial",
            "score": 75,
            "notes": "Cliente ha mostrado interés en visita",
            "updated_at": "2024-01-16 14:20:00"
        }
    }
}
```

**Response 404:**
```json
{
    "success": false,
    "message": "Cliente no encontrado"
}
```

**Response 403:**
```json
{
    "success": false,
    "message": "No tienes permiso para acceder a este cliente"
}
```

---

### 5. Obtener Opciones para Formularios (GET)

Obtener las opciones disponibles para los campos de selección.

**Endpoint:** `GET /clients/options`

**Rate Limit:** 120 solicitudes por minuto (puede cachearse)

**Response 200:**
```json
{
    "success": true,
    "message": "Opciones obtenidas exitosamente",
    "data": {
        "document_types": {
            "DNI": "DNI",
            "RUC": "RUC",
            "CE": "Carné de Extranjería",
            "PASAPORTE": "Pasaporte"
        },
        "client_types": {
            "inversor": "Inversor",
            "comprador": "Comprador",
            "empresa": "Empresa",
            "constructor": "Constructor"
        },
        "sources": {
            "redes_sociales": "Redes Sociales",
            "ferias": "Ferias",
            "referidos": "Referidos",
            "formulario_web": "Formulario Web",
            "publicidad": "Publicidad"
        },
        "statuses": {
            "nuevo": "Nuevo",
            "contacto_inicial": "Contacto Inicial",
            "en_seguimiento": "En Seguimiento",
            "cierre": "Cierre",
            "perdido": "Perdido"
        }
    }
}
```

**💡 Recomendación:** Cachea esta respuesta en la app móvil ya que rara vez cambia.

---

## 📊 Modelos de Datos

### Tipos de Documento

| Valor | Descripción |
|-------|-------------|
| `DNI` | Documento Nacional de Identidad |
| `RUC` | Registro Único de Contribuyente |
| `CE` | Carné de Extranjería |
| `PASAPORTE` | Pasaporte |

### Tipos de Cliente

| Valor | Descripción |
|-------|-------------|
| `inversor` | Inversor |
| `comprador` | Comprador |
| `empresa` | Empresa |
| `constructor` | Constructor |

### Orígenes

| Valor | Descripción |
|-------|-------------|
| `redes_sociales` | Redes Sociales |
| `ferias` | Ferias |
| `referidos` | Referidos |
| `formulario_web` | Formulario Web |
| `publicidad` | Publicidad |

### Estados

| Valor | Descripción |
|-------|-------------|
| `nuevo` | Nuevo |
| `contacto_inicial` | Contacto Inicial |
| `en_seguimiento` | En Seguimiento |
| `cierre` | Cierre |
| `perdido` | Perdido |

---

## ⚠️ Manejo de Errores

### Códigos de Estado HTTP

| Código | Significado | Descripción |
|--------|-------------|-------------|
| `200` | OK | Solicitud exitosa |
| `201` | Created | Recurso creado exitosamente |
| `401` | Unauthorized | No autenticado o token inválido |
| `403` | Forbidden | Acceso denegado (no es datero o no es el propietario) |
| `404` | Not Found | Recurso no encontrado |
| `422` | Unprocessable Entity | Error de validación |
| `429` | Too Many Requests | Rate limit excedido |
| `500` | Internal Server Error | Error del servidor |

### Estructura de Error

```json
{
    "success": false,
    "message": "Mensaje descriptivo del error",
    "errors": {
        "campo": ["Mensaje de error específico"]
    }
}
```

---

## 📱 Implementación Flutter

### Dependencias Requeridas

Agrega estas dependencias a tu `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  dio: ^5.4.0  # Alternativa más robusta a http
```

### 1. Modelos de Datos Dart

**models/user_model.dart:**
```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
    );
  }
}
```

**models/client_model.dart:**
```dart
class ClientModel {
  final int id;
  final String name;
  final String? phone;
  final String documentType;
  final String documentNumber;
  final String? address;
  final String? birthDate;
  final String clientType;
  final String source;
  final String status;
  final int score;
  final String? notes;
  final AdvisorModel? assignedAdvisor;
  final int? opportunitiesCount;
  final int? activitiesCount;
  final int? tasksCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.name,
    this.phone,
    required this.documentType,
    required this.documentNumber,
    this.address,
    this.birthDate,
    required this.clientType,
    required this.source,
    required this.status,
    required this.score,
    this.notes,
    this.assignedAdvisor,
    this.opportunitiesCount,
    this.activitiesCount,
    this.tasksCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      address: json['address'],
      birthDate: json['birth_date'],
      clientType: json['client_type'],
      source: json['source'],
      status: json['status'],
      score: json['score'],
      notes: json['notes'],
      assignedAdvisor: json['assigned_advisor'] != null
          ? AdvisorModel.fromJson(json['assigned_advisor'])
          : null,
      opportunitiesCount: json['opportunities_count'],
      activitiesCount: json['activities_count'],
      tasksCount: json['tasks_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'document_type': documentType,
      'document_number': documentNumber,
      'address': address,
      'birth_date': birthDate,
      'client_type': clientType,
      'source': source,
      'status': status,
      'score': score,
      'notes': notes,
      if (assignedAdvisor != null) 'assigned_advisor_id': assignedAdvisor!.id,
    };
  }
}

class AdvisorModel {
  final int id;
  final String name;
  final String email;

  AdvisorModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
```

**models/api_response.dart:**
```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }
}
```

### 2. Servicio de Autenticación

**services/auth_service.dart:**
```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

class AuthService {
  final Dio _dio;
  static const String _baseUrl = 'https://tu-dominio.com/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService() : _dio = Dio(BaseOptions(
      baseURL: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => Map<String, dynamic>.from(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Guardar token
        final token = apiResponse.data!['token'] as String;
        await _saveToken(token);

        // Guardar usuario
        final userData = apiResponse.data!['user'] as Map<String, dynamic>;
        await _saveUser(userData);
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Obtener usuario autenticado
  Future<ApiResponse<UserModel>> getMe() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token guardado');
      }

      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }

      await _clearAuth();
      return const ApiResponse(success: true, message: 'Sesión cerrada');
    } on DioException catch (e) {
      await _clearAuth();
      return _handleError(e);
    }
  }

  // Refrescar token
  Future<ApiResponse<String>> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token guardado');
      }

      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => Map<String, dynamic>.from(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final newToken = apiResponse.data!['token'] as String;
        await _saveToken(newToken);
        return ApiResponse<String>(
          success: true,
          message: apiResponse.message,
          data: newToken,
        );
      }

      return ApiResponse<String>(
        success: false,
        message: apiResponse.message,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Token helpers
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiResponse<T>.fromJson(
        data is Map ? data : {'success': false, 'message': e.message},
        null,
      );
    }
    return ApiResponse<T>(
      success: false,
      message: e.message ?? 'Error de conexión',
    );
  }
}
```

### 3. Servicio de Clientes

**services/client_service.dart:**
```dart
import 'package:dio/dio.dart';
import '../models/client_model.dart';
import '../models/api_response.dart';
import 'auth_service.dart';

class ClientService {
  final Dio _dio;
  final AuthService _authService;

  ClientService(this._authService) : _dio = Dio(BaseOptions(
      baseURL: 'https://tu-dominio.com/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )) {
    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Si el token expiró, intentar refrescar
        if (error.response?.statusCode == 401) {
          final refreshResponse = await _authService.refreshToken();
          if (refreshResponse.success && refreshResponse.data != null) {
            // Reintentar la petición
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${refreshResponse.data}';
            final response = await _dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));
  }

  // Listar clientes
  Future<ApiResponse<ClientListResponse>> getClients({
    int perPage = 15,
    String? search,
    String? status,
    String? type,
    String? source,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
        'page': page,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (source != null && source.isNotEmpty) {
        queryParams['source'] = source;
      }

      final response = await _dio.get(
        '/clients',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => Map<String, dynamic>.from(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final clientsList = (apiResponse.data!['clients'] as List)
            .map((e) => ClientModel.fromJson(e))
            .toList();
        final pagination = apiResponse.data!['pagination'] as Map<String, dynamic>;

        return ApiResponse<ClientListResponse>(
          success: true,
          message: apiResponse.message,
          data: ClientListResponse(
            clients: clientsList,
            pagination: PaginationInfo.fromJson(pagination),
          ),
        );
      }

      return ApiResponse<ClientListResponse>(
        success: false,
        message: apiResponse.message,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Ver cliente específico
  Future<ApiResponse<ClientModel>> getClient(int id) async {
    try {
      final response = await _dio.get('/clients/$id');

      return ApiResponse<ClientModel>.fromJson(
        response.data,
        (data) => ClientModel.fromJson(data['client']),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Crear cliente
  Future<ApiResponse<ClientModel>> createClient(ClientModel client) async {
    try {
      final response = await _dio.post(
        '/clients',
        data: client.toJson(),
      );

      return ApiResponse<ClientModel>.fromJson(
        response.data,
        (data) => ClientModel.fromJson(data['client']),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Actualizar cliente
  Future<ApiResponse<ClientModel>> updateClient(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/clients/$id',
        data: data,
      );

      return ApiResponse<ClientModel>.fromJson(
        response.data,
        (data) => ClientModel.fromJson(data['client']),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Obtener opciones
  Future<ApiResponse<ClientOptions>> getOptions() async {
    try {
      final response = await _dio.get('/clients/options');

      return ApiResponse<ClientOptions>.fromJson(
        response.data,
        (data) => ClientOptions.fromJson(data),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      return ApiResponse<T>.fromJson(
        data is Map ? data : {'success': false, 'message': e.message},
        null,
      );
    }
    return ApiResponse<T>(
      success: false,
      message: e.message ?? 'Error de conexión',
    );
  }
}

// Modelos auxiliares
class ClientListResponse {
  final List<ClientModel> clients;
  final PaginationInfo pagination;

  ClientListResponse({
    required this.clients,
    required this.pagination,
  });
}

class PaginationInfo {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int? from;
  final int? to;

  PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
      from: json['from'],
      to: json['to'],
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}

class ClientOptions {
  final Map<String, String> documentTypes;
  final Map<String, String> clientTypes;
  final Map<String, String> sources;
  final Map<String, String> statuses;

  ClientOptions({
    required this.documentTypes,
    required this.clientTypes,
    required this.sources,
    required this.statuses,
  });

  factory ClientOptions.fromJson(Map<String, dynamic> json) {
    return ClientOptions(
      documentTypes: Map<String, String>.from(json['document_types']),
      clientTypes: Map<String, String>.from(json['client_types']),
      sources: Map<String, String>.from(json['sources']),
      statuses: Map<String, String>.from(json['statuses']),
    );
  }
}
```

### 4. Ejemplo de Uso

**Ejemplo en un Widget:**
```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/client_service.dart';
import '../models/client_model.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final AuthService _authService = AuthService();
  late ClientService _clientService;
  List<ClientModel> _clients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientService = ClientService(_authService);
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _clientService.getClients(
      perPage: 20,
      search: null,
    );

    if (response.success && response.data != null) {
      setState(() {
        _clients = response.data!.clients;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Clientes')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Clientes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              ElevatedButton(
                onPressed: _loadClients,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Clientes')),
      body: RefreshIndicator(
        onRefresh: _loadClients,
        child: ListView.builder(
          itemCount: _clients.length,
          itemBuilder: (context, index) {
            final client = _clients[index];
            return ListTile(
              title: Text(client.name),
              subtitle: Text(client.documentNumber),
              trailing: Chip(label: Text(client.status)),
              onTap: () {
                // Navegar a detalle
              },
            );
          },
        ),
      ),
    );
  }
}
```

---

## 🚦 Rate Limiting

La API implementa rate limiting para proteger el servidor:

| Endpoint | Límite |
|----------|--------|
| `/auth/login` | 5 solicitudes por minuto |
| `/clients/*` (general) | 60 solicitudes por minuto |
| `/clients/options` | 120 solicitudes por minuto |

**Respuesta 429 (Too Many Requests):**
```json
{
    "success": false,
    "message": "Too Many Requests"
}
```

**Recomendaciones:**
- Cachea las respuestas cuando sea posible (especialmente `/clients/options`)
- Implementa retry con backoff exponencial
- No hagas polling agresivo; usa WebSockets o notificaciones push si es necesario

---

## 💡 Mejores Prácticas

### 1. Manejo de Tokens

- ✅ Guarda el token de forma segura usando `shared_preferences` o `flutter_secure_storage`
- ✅ Refresca el token antes de que expire
- ✅ Maneja errores 401 refrescando el token automáticamente
- ✅ Limpia el token al hacer logout

### 2. Caché y Offline

- ✅ Cachea las opciones de formularios (`/clients/options`)
- ✅ Implementa almacenamiento local para trabajar offline
- ✅ Sincroniza datos cuando vuelva la conexión

### 3. Manejo de Errores

- ✅ Maneja todos los códigos de estado HTTP
- ✅ Muestra mensajes de error amigables al usuario
- ✅ Implementa retry lógico para errores temporales
- ✅ Registra errores para debugging

### 4. Optimización de Red

- ✅ Usa paginación en lugar de cargar todos los datos
- ✅ Implementa búsqueda con debounce
- ✅ Carga datos bajo demanda (lazy loading)
- ✅ Compresa las peticiones cuando sea posible

### 5. UX/UI

- ✅ Muestra indicadores de carga
- ✅ Implementa pull-to-refresh
- ✅ Valida datos en el cliente antes de enviar
- ✅ Muestra mensajes de éxito/error claros

---

## 📝 Notas Finales

- Todos los endpoints retornan JSON
- Los errores siguen un formato consistente
- El token JWT debe incluirse en todas las peticiones protegidas
- El tiempo de expiración del token se indica en segundos en `expires_in`
- Los campos de fecha deben estar en formato `YYYY-MM-DD`
- El `document_number` debe ser único en el sistema

---

## 🔗 Referencias

- [Documentación JWT Auth](https://jwt-auth.readthedocs.io/)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Dio Package](https://pub.dev/packages/dio)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)

---

**Versión de API:** 1.0.0  
**Última actualización:** 2024-01-15
