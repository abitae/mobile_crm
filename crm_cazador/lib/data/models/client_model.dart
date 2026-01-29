/// Modelo de cliente para Cazador
class ClientModel {
  final int id;
  final String name;
  final String documentType;
  final String documentNumber;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? birthDate;
  final String type;
  final String status;
  final String source;
  final int score;
  final String? notes;
  final int? userId;
  final int? assignedAdvisorId;
  final Map<String, dynamic>? assignedAdvisor;
  final int? opportunitiesCount;
  final int? activitiesCount;
  final int? tasksCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createType;

  /// Modo de creación según backend: `dni` o `phone`.
  /// - `dni`: document_type y document_number son obligatorios.
  /// - `phone`: DNI es opcional.
  final String? createMode;

  ClientModel({
    required this.id,
    required this.name,
    required this.documentType,
    required this.documentNumber,
    this.phone,
    this.email,
    this.address,
    this.birthDate,
    required this.type,
    required this.status,
    required this.source,
    required this.score,
    this.notes,
    this.userId,
    this.assignedAdvisorId,
    this.assignedAdvisor,
    this.opportunitiesCount,
    this.activitiesCount,
    this.tasksCount,
    this.createdAt,
    this.updatedAt,
    this.createType,
    this.createMode,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    // Normalizar documentType a 'DNI' siempre
    final docType = json['document_type'] as String? ?? 'DNI';
    final normalizedDocType = docType.toUpperCase() == 'DNI' ? 'DNI' : 'DNI';
    
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      documentType: normalizedDocType,
      documentNumber: json['document_number'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      type: (json['client_type'] ?? json['type']) as String,
      status: json['status'] as String,
      source: json['source'] as String,
      score: json['score'] as int? ?? 0,
      notes: json['notes'] as String?,
      userId: json['user_id'] as int?,
      assignedAdvisorId: json['assigned_advisor_id'] as int?,
      assignedAdvisor: json['assigned_advisor'] as Map<String, dynamic>?,
      opportunitiesCount: json['opportunities_count'] as int?,
      activitiesCount: json['activities_count'] as int?,
      tasksCount: json['tasks_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createType: json['create_type'] as String?,
      createMode: json['create_mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'document_type': documentType,
      'document_number': documentNumber,
      'phone': phone,
      'email': email,
      'address': address,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'client_type': type,
      'status': status,
      'source': source,
      'score': score,
      'notes': notes,
      'user_id': userId,
      'assigned_advisor_id': assignedAdvisorId,
      if (createType != null) 'create_type': createType,
      if (createMode != null) 'create_mode': createMode,
    };
  }

  Map<String, dynamic> toPartialJson() {
    final map = <String, dynamic>{};
    if (name.isNotEmpty) map['name'] = name;

    final mode = (createMode ?? '').isNotEmpty
        ? createMode!
        : (documentNumber.isNotEmpty ? 'dni' : 'phone');
    map['create_mode'] = mode;

    // Documentos:
    // - Si mode == 'dni', siempre enviar document_type y document_number.
    // - Si mode == 'phone', enviar document_type DNI y document_number placeholder si está vacío.
    if (mode == 'dni' || documentType.isNotEmpty) {
      map['document_type'] = documentType;
    } else if (mode == 'phone') {
      map['document_type'] = 'DNI';
    }
    if (mode == 'dni' || documentNumber.isNotEmpty) {
      map['document_number'] = documentNumber;
    } else if (mode == 'phone') {
      map['document_number'] = '00000000';
    }

    final sanitizedPhone = phone?.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedPhone != null && sanitizedPhone.isNotEmpty) {
      map['phone'] = sanitizedPhone;
    }
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    if (birthDate != null) {
      map['birth_date'] = birthDate!.toIso8601String().split('T')[0];
    }
    map['client_type'] = type;
    map['status'] = status;
    map['source'] = source;
    map['score'] = score;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    if (createType != null) map['create_type'] = createType;
    return map;
  }

  Map<String, dynamic> toCreateJson() {
    // Determinar create_mode: si no viene, asumir 'dni' como valor por defecto.
    final mode = (createMode ?? '').isNotEmpty ? createMode! : 'dni';

    // Sanitizar teléfono (solo dígitos) para cumplir con validación de backend.
    final sanitizedPhone = phone
        ?.replaceAll(RegExp(r'[^0-9]'), '');

    final data = <String, dynamic>{
      'name': name,
      'create_mode': mode,
    // Documentos:
    // - Si mode == 'dni', siempre enviar document_type y document_number.
    // - Si mode == 'phone', enviar document_type DNI y document_number placeholder si está vacío.
    if (mode == 'dni' || documentType.isNotEmpty) 'document_type': documentType,
    if (mode == 'phone' && (documentType.isEmpty)) 'document_type': 'DNI',
    if (mode == 'dni' || documentNumber.isNotEmpty) 'document_number': documentNumber,
    if (mode == 'phone' && documentNumber.isEmpty) 'document_number': '00000000',
      'phone': sanitizedPhone,
      'email': email,
      'address': address,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'client_type': type,
      'status': status,
      'source': source,
      'score': score,
      'notes': notes,
      if (createType != null) 'create_type': createType,
      // Nota: assigned_advisor_id se asigna automáticamente en el backend
    };

    return data;
  }
}

