/// Modelo de Actividad para Clientes
class ActivityModel {
  final int? id;
  final int clientId;
  final String type; // llamada, reunion, email, visita, etc.
  final String description;
  final DateTime? activityDate;
  final String? notes;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ActivityModel({
    this.id,
    required this.clientId,
    required this.type,
    required this.description,
    this.activityDate,
    this.notes,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int?,
      clientId: json['client_id'] as int,
      type: json['type'] as String,
      description: json['description'] as String,
      activityDate: json['activity_date'] != null
          ? DateTime.parse(json['activity_date'] as String)
          : null,
      notes: json['notes'] as String?,
      userId: json['user_id'] as int?,
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
      'client_id': clientId,
      'type': type,
      'description': description,
      'activity_date': activityDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'user_id': userId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type,
      'description': description,
      if (activityDate != null)
        'activity_date': activityDate!.toIso8601String().split('T')[0],
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
