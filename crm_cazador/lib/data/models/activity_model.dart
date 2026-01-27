/// Modelo de Actividad para Clientes
/// 
/// Campos requeridos para crear actividad (POST /clients/{client}/activities):
/// - title (string): Título de la actividad
/// - activity_type (string): Tipo de actividad (llamada|reunion|visita|seguimiento|tarea)
/// - start_date (datetime): Fecha y hora de inicio
/// 
/// Campos opcionales para crear actividad:
/// - description (string): Descripción de la actividad
/// - status (string): programada|en_progreso|completada|cancelada (default: programada)
/// - priority (string): baja|media|alta|urgente (default: media)
/// - duration (int): Duración en minutos
/// - location (string): Ubicación
/// - notes (string): Notas adicionales
/// - project_id, unit_id, opportunity_id, advisor_id, assigned_to, reminder_before, result
class ActivityModel {
  final int? id;
  final int clientId;
  final String title; // Título de la actividad (requerido)
  final String? description; // Descripción opcional
  final String activityType; // llamada|reunion|visita|seguimiento|tarea (requerido)
  final DateTime? startDate; // Fecha y hora de inicio (requerido)
  final String? status; // programada|en_progreso|completada|cancelada
  final String? priority; // baja|media|alta|urgente
  final int? duration; // Duración en minutos
  final String? location; // Ubicación
  final String? notes; // Notas adicionales
  final String? result; // Resultado de la actividad
  final int? projectId;
  final int? unitId;
  final int? opportunityId;
  final int? advisorId;
  final int? assignedTo; // ID del usuario asignado
  final int? reminderBefore; // Minutos antes para recordatorio
  final bool? reminderSent;
  final int? createdBy;
  final int? updatedBy;
  final Map<String, dynamic>? advisor; // Relación con el asesor
  final Map<String, dynamic>? assignedToUser; // Relación con el usuario asignado
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ActivityModel({
    this.id,
    required this.clientId,
    required this.title,
    this.description,
    required this.activityType,
    this.startDate,
    this.status,
    this.priority,
    this.duration,
    this.location,
    this.notes,
    this.result,
    this.projectId,
    this.unitId,
    this.opportunityId,
    this.advisorId,
    this.assignedTo,
    this.reminderBefore,
    this.reminderSent,
    this.createdBy,
    this.updatedBy,
    this.advisor,
    this.assignedToUser,
    this.createdAt,
    this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    // Helper para parsear enteros de forma segura
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper para parsear fechas de forma segura
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Helper para parsear booleanos
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return null;
    }

    // Parsear client_id - requerido
    final clientId = parseInt(json['client_id']);
    if (clientId == null) {
      throw Exception('client_id es requerido y no puede ser null');
    }

    // Parsear title (requerido según documentación)
    final title = json['title'] as String? ?? '';
    if (title.isEmpty) {
      // Fallback: si no hay title, usar description o type como título
      final fallbackTitle = json['description'] as String? ?? 
                           json['type'] as String? ?? 
                           json['activity_type'] as String? ?? 
                           'Actividad';
      // No lanzamos error, solo usamos fallback
    }

    // Parsear activity_type (puede venir como 'type' o 'activity_type')
    final activityType = json['activity_type'] as String? ?? 
                        json['type'] as String? ?? 
                        'llamada';

    // Parsear start_date (puede venir como 'start_date' o 'activity_date')
    DateTime? startDate;
    if (json.containsKey('start_date') && json['start_date'] != null) {
      startDate = parseDate(json['start_date']);
    } else if (json.containsKey('activity_date') && json['activity_date'] != null) {
      startDate = parseDate(json['activity_date']);
    }

    // Parsear assigned_to (puede ser int o objeto)
    int? assignedToId;
    Map<String, dynamic>? assignedToUserObj;
    if (json['assigned_to'] != null) {
      if (json['assigned_to'] is int || json['assigned_to'] is num) {
        assignedToId = parseInt(json['assigned_to']);
      } else if (json['assigned_to'] is Map) {
        assignedToUserObj = json['assigned_to'] as Map<String, dynamic>;
        assignedToId = parseInt(assignedToUserObj?['id']);
      }
    }

    // Parsear advisor (puede ser int o objeto)
    int? advisorId;
    Map<String, dynamic>? advisorObj;
    if (json['advisor'] != null) {
      if (json['advisor'] is int || json['advisor'] is num) {
        advisorId = parseInt(json['advisor']);
      } else if (json['advisor'] is Map) {
        advisorObj = json['advisor'] as Map<String, dynamic>;
        advisorId = parseInt(advisorObj?['id']);
      }
    } else if (json['advisor_id'] != null) {
      advisorId = parseInt(json['advisor_id']);
    }

    return ActivityModel(
      id: parseInt(json['id']),
      clientId: clientId,
      title: title.isEmpty ? (json['description'] as String? ?? json['type'] as String? ?? 'Actividad') : title,
      description: json['description'] as String?,
      activityType: activityType,
      startDate: startDate,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      duration: parseInt(json['duration']),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      result: json['result'] as String?,
      projectId: parseInt(json['project_id']),
      unitId: parseInt(json['unit_id']),
      opportunityId: parseInt(json['opportunity_id']),
      advisorId: advisorId,
      assignedTo: assignedToId,
      reminderBefore: parseInt(json['reminder_before']),
      reminderSent: parseBool(json['reminder_sent']),
      createdBy: parseInt(json['created_by']),
      updatedBy: parseInt(json['updated_by']),
      advisor: advisorObj,
      assignedToUser: assignedToUserObj ?? json['assigned_to_user'] as Map<String, dynamic>?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'title': title,
      'description': description,
      'activity_type': activityType,
      'start_date': startDate?.toIso8601String(),
      'status': status,
      'priority': priority,
      'duration': duration,
      'location': location,
      'notes': notes,
      'result': result,
      'project_id': projectId,
      'unit_id': unitId,
      'opportunity_id': opportunityId,
      'advisor_id': advisorId,
      'assigned_to': assignedTo,
      'reminder_before': reminderBefore,
      'reminder_sent': reminderSent,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'advisor': advisor,
      'assigned_to_user': assignedToUser,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// JSON para crear una nueva actividad
  /// Campos requeridos según documentación: title, activity_type, start_date
  /// Campos opcionales: description, status, priority, duration, location, notes, etc.
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'activity_type': activityType,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (description != null && description!.isNotEmpty) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (duration != null) 'duration': duration,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (projectId != null) 'project_id': projectId,
      if (unitId != null) 'unit_id': unitId,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (advisorId != null) 'advisor_id': advisorId,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (reminderBefore != null) 'reminder_before': reminderBefore,
      if (result != null && result!.isNotEmpty) 'result': result,
    };
  }

  /// JSON para actualizar una actividad existente
  /// Campos permitidos según documentación: status, result, notes, start_date, assigned_to
  Map<String, dynamic> toUpdateJson() {
    return {
      if (status != null) 'status': status,
      if (result != null) 'result': result,
      if (notes != null) 'notes': notes,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (assignedTo != null) 'assigned_to': assignedTo,
    };
  }
}
