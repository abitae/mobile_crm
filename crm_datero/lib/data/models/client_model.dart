/// Modelo de cliente
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
  final int? opportunitiesCount;
  final int? activitiesCount;
  final int? tasksCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.opportunitiesCount,
    this.activitiesCount,
    this.tasksCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    // Normalizar documentType a 'DNI' siempre
    final docType = json['document_type'] as String? ?? 'DNI';
    final normalizedDocType = docType.toUpperCase() == 'DNI' ? 'DNI' : 'DNI';
    
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      documentType: normalizedDocType,
      documentNumber: json['document_number'] as String,
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
      opportunitiesCount: json['opportunities_count'] as int?,
      activitiesCount: json['activities_count'] as int?,
      tasksCount: json['tasks_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
    };
  }

  /// Crea un mapa solo con los campos que se pueden actualizar (PATCH)
  Map<String, dynamic> toPartialJson() {
    final map = <String, dynamic>{};
    if (name.isNotEmpty) map['name'] = name;
    // document_type y document_number son obligatorios al actualizar
    map['document_type'] = documentType;
    map['document_number'] = documentNumber;
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (address != null && address!.isNotEmpty) map['address'] = address;
    if (birthDate != null) {
      map['birth_date'] = birthDate!.toIso8601String().split('T')[0];
    }
    map['type'] = type;
    map['status'] = status;
    map['source'] = source;
    map['score'] = score;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }

  /// Crea un mapa para crear nuevo cliente (POST)
  Map<String, dynamic> toCreateJson() {
    return {
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
    };
  }
}

