/// Modelo genérico para respuestas de la API
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final Map<String, dynamic>? errors;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'success': success,
      'errors': errors,
    };
  }
}

import '../../core/logging/app_logger.dart';

/// Modelo de link de paginación
class PaginationLink {
  final String? url;
  final String label;
  final bool? active;

  PaginationLink({
    this.url,
    required this.label,
    this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'] as String?,
      label: json['label'] as String? ?? '',
      active: json['active'] as bool?,
    );
  }
}

/// Metadatos de paginación mejorada del backend
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final int? from;
  final int? to;
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  final List<PaginationLink>? links;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.from,
    this.to,
    this.hasNextPage,
    this.hasPreviousPage,
    this.links,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final links = json['links'] as List<dynamic>?;
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 15,
      from: json['from'] as int?,
      to: json['to'] as int?,
      hasNextPage: json['has_next'] as bool? ?? json['has_next_page'] as bool?,
      hasPreviousPage: json['has_previous'] as bool? ?? json['has_previous_page'] as bool?,
      links: links?.map((link) => PaginationLink.fromJson(link as Map<String, dynamic>)).toList(),
    );
  }

  /// Verificar si hay más páginas
  bool get hasMore => hasNextPage ?? (currentPage < lastPage);

  /// Verificar si hay página anterior
  bool get hasPrevious => hasPreviousPage ?? (currentPage > 1);
}

/// Respuesta paginada de la API con metadatos mejorados
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final PaginationMeta? meta;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    this.meta,
  });

  /// Verificar si hay más páginas (usa meta si está disponible)
  bool get hasMore => meta?.hasMore ?? (currentPage < totalPages);

  /// Verificar si hay página anterior (usa meta si está disponible)
  bool get hasPrevious => meta?.hasPrevious ?? (currentPage > 1);

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataObj = json['data'];
    PaginationMeta? meta;
    Map<String, dynamic>? pagination;
    List<dynamic>? items;
    
    // Intentar extraer paginación y datos según diferentes estructuras
    if (dataObj is Map<String, dynamic>) {
      // Estructura con objeto data que contiene items y pagination
      if (dataObj.containsKey('clients')) {
        items = dataObj['clients'] as List<dynamic>? ?? [];
        pagination = dataObj['pagination'] as Map<String, dynamic>?;
      } else if (dataObj.containsKey('projects')) {
        items = dataObj['projects'] as List<dynamic>? ?? [];
        pagination = dataObj['pagination'] as Map<String, dynamic>?;
      } else if (dataObj.containsKey('reservations')) {
        items = dataObj['reservations'] as List<dynamic>? ?? [];
        pagination = dataObj['pagination'] as Map<String, dynamic>?;
      } else if (dataObj.containsKey('dateros')) {
        items = dataObj['dateros'] as List<dynamic>? ?? [];
        pagination = dataObj['pagination'] as Map<String, dynamic>?;
      } else if (dataObj.containsKey('units')) {
        items = dataObj['units'] as List<dynamic>? ?? [];
        pagination = dataObj['pagination'] as Map<String, dynamic>?;
      }
    } else if (dataObj is List<dynamic>) {
      // Estructura directa con array de datos
      items = dataObj;
      pagination = json['pagination'] as Map<String, dynamic>?;
    }
    
    // Si no se encontró items, intentar usar data directamente
    // Verificar que data sea una List antes de hacer el cast
    final dataValue = json['data'];
    if (items == null && dataValue is List<dynamic>) {
      items = dataValue;
    }
    pagination ??= json['pagination'] as Map<String, dynamic>?;
    
    // Crear meta si hay paginación
    if (pagination != null) {
      // Intentar usar meta si está disponible (formato mejorado)
      final metaObj = pagination['meta'] as Map<String, dynamic>?;
      if (metaObj != null) {
        meta = PaginationMeta.fromJson(metaObj);
      } else {
        // Usar paginación directa y crear meta
        meta = PaginationMeta.fromJson(pagination);
      }
    }
    
    // Si no se encontraron items, intentar más estrategias
    if (items == null) {
      // Estrategia adicional: verificar si dataObj tiene alguna clave que pueda ser una lista
      if (dataObj is Map<String, dynamic>) {
        // Buscar cualquier clave que contenga una lista
        for (final entry in dataObj.entries) {
          if (entry.value is List<dynamic>) {
            items = entry.value as List<dynamic>;
            AppLogger.debug('Items encontrados en clave: ${entry.key}', tag: 'PaginatedResponse');
            break;
          }
        }
      }
      
      // Si aún no se encontraron items, lanzar error descriptivo
      if (items == null) {
        final errorMsg = 'No se pudo extraer la lista de items de la respuesta. '
            'Estructura esperada: {data: {clients|projects|reservations|dateros: [...]}, pagination: {...}} '
            'o {data: [...], pagination: {...}}. '
            'Estructura recibida: ${json.keys}. '
            'Tipo de data: ${dataObj.runtimeType}. '
            'Contenido de data: ${dataObj is Map ? (dataObj as Map).keys : 'N/A'}';
        
        AppLogger.error(errorMsg, tag: 'PaginatedResponse', data: {'json': json});
        throw FormatException(errorMsg);
      }
    }
    
    return PaginatedResponse<T>(
      data: items.map((item) => fromJsonT(item)).toList(),
      currentPage: meta?.currentPage ?? pagination?['current_page'] as int? ?? 1,
      totalPages: meta?.lastPage ?? pagination?['last_page'] as int? ?? 1,
      totalItems: meta?.total ?? pagination?['total'] as int? ?? 0,
      perPage: meta?.perPage ?? pagination?['per_page'] as int? ?? 15,
      meta: meta,
    );
  }
}

