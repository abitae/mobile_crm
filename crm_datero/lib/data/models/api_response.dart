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

/// Respuesta paginada de la API
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    // Manejar estructura de respuesta de la API según documentación:
    // { "success": true, "data": { "clients": [...], "pagination": {...} } }
    final dataObj = json['data'];
    
    // Si data es un objeto con 'clients' y 'pagination', usar esa estructura
    if (dataObj is Map<String, dynamic> && dataObj.containsKey('clients')) {
      final clients = dataObj['clients'] as List<dynamic>? ?? [];
      final pagination = dataObj['pagination'] as Map<String, dynamic>? ?? {};
      
      return PaginatedResponse<T>(
        data: clients.map((item) => fromJsonT(item)).toList(),
        currentPage: pagination['current_page'] as int? ?? 1,
        totalPages: pagination['last_page'] as int? ?? 1,
        totalItems: pagination['total'] as int? ?? 0,
        perPage: pagination['per_page'] as int? ?? 15,
      );
    }
    
    // Fallback: estructura antigua o directa
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['last_page'] as int? ?? 1,
      totalItems: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 15,
    );
  }
}

