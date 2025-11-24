/// Modelo para la respuesta de búsqueda de documentos
class DocumentSearchResponse {
  final bool found;
  final String documentType;
  final String documentNumber;
  final DocumentData? data;
  final Ubigeo? ubigeo;

  DocumentSearchResponse({
    required this.found,
    required this.documentType,
    required this.documentNumber,
    this.data,
    this.ubigeo,
  });

  factory DocumentSearchResponse.fromJson(Map<String, dynamic> json) {
    return DocumentSearchResponse(
      found: json['found'] as bool? ?? false,
      documentType: json['document_type'] as String? ?? '',
      documentNumber: json['document_number'] as String? ?? '',
      data: json['data'] != null
          ? DocumentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      ubigeo: json['ubigeo'] != null
          ? Ubigeo.fromJson(json['ubigeo'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Datos del documento encontrado
class DocumentData {
  final String? nombres;
  final String? apPaterno;
  final String? apMaterno;
  final String? nombre; // Nombre completo
  final String? fechaNacimiento;
  final String? codigoUbigeo;
  final ApiResult? api;

  DocumentData({
    this.nombres,
    this.apPaterno,
    this.apMaterno,
    this.nombre,
    this.fechaNacimiento,
    this.codigoUbigeo,
    this.api,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      nombres: json['nombres'] as String?,
      apPaterno: json['ap_paterno'] as String?,
      apMaterno: json['ap_materno'] as String?,
      nombre: json['nombre'] as String?, // Nombre completo ya viene en la API
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      codigoUbigeo: json['codigo_ubigeo'] as String?,
      api: json['api'] != null
          ? ApiResult.fromJson(json['api'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Obtener el nombre completo
  /// Prioriza el campo 'nombre' si está disponible, sino construye desde partes
  String get fullName {
    if (nombre != null && nombre!.isNotEmpty) {
      return nombre!;
    }
    final parts = <String>[];
    if (nombres != null && nombres!.isNotEmpty) parts.add(nombres!);
    if (apPaterno != null && apPaterno!.isNotEmpty) {
      parts.add(apPaterno!);
    }
    if (apMaterno != null && apMaterno!.isNotEmpty) {
      parts.add(apMaterno!);
    }
    return parts.join(' ');
  }
}

/// Resultado de la API externa
class ApiResult {
  final Result? result;

  ApiResult({this.result});

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      result: json['result'] != null
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Datos de dirección de la API
class Result {
  final String? depaDireccion;
  final String? provDireccion;
  final String? distDireccion;

  Result({
    this.depaDireccion,
    this.provDireccion,
    this.distDireccion,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      depaDireccion: json['depaDireccion'] as String?,
      provDireccion: json['provDireccion'] as String?,
      distDireccion: json['distDireccion'] as String?,
    );
  }

  /// Obtener dirección completa
  String get fullAddress {
    final parts = <String>[];
    if (distDireccion != null && distDireccion!.isNotEmpty) {
      parts.add(distDireccion!);
    }
    if (provDireccion != null && provDireccion!.isNotEmpty) {
      parts.add(provDireccion!);
    }
    if (depaDireccion != null && depaDireccion!.isNotEmpty) {
      parts.add(depaDireccion!);
    }
    return parts.join(', ');
  }
}

/// Información de ubigeo
class Ubigeo {
  final String text;
  final String code;

  Ubigeo({
    required this.text,
    required this.code,
  });

  factory Ubigeo.fromJson(Map<String, dynamic> json) {
    return Ubigeo(
      text: json['text'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

