/// Modelo de comisión
class CommissionModel {
  final int id;
  final ProjectInfo? project;
  final UnitInfo? unit;
  final OpportunityInfo? opportunity;
  final String commissionType;
  final double baseAmount;
  final double commissionPercentage;
  final double commissionAmount;
  final double bonusAmount;
  final double totalCommission;
  final String status;
  final String? paymentDate;
  final String? paymentMethod;
  final String? paymentReference;
  final String? notes;
  final String? approvedAt;
  final String? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommissionModel({
    required this.id,
    this.project,
    this.unit,
    this.opportunity,
    required this.commissionType,
    required this.baseAmount,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.bonusAmount,
    required this.totalCommission,
    required this.status,
    this.paymentDate,
    this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.approvedAt,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'] as int,
      project: json['project'] != null
          ? ProjectInfo.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      unit: json['unit'] != null
          ? UnitInfo.fromJson(json['unit'] as Map<String, dynamic>)
          : null,
      opportunity: json['opportunity'] != null
          ? OpportunityInfo.fromJson(json['opportunity'] as Map<String, dynamic>)
          : null,
      commissionType: json['commission_type'] as String,
      baseAmount: (json['base_amount'] as num).toDouble(),
      commissionPercentage: (json['commission_percentage'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      bonusAmount: (json['bonus_amount'] as num).toDouble(),
      totalCommission: (json['total_commission'] as num).toDouble(),
      status: json['status'] as String,
      paymentDate: json['payment_date'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      notes: json['notes'] as String?,
      approvedAt: json['approved_at'] as String?,
      paidAt: json['paid_at'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project': project?.toJson(),
      'unit': unit?.toJson(),
      'opportunity': opportunity?.toJson(),
      'commission_type': commissionType,
      'base_amount': baseAmount,
      'commission_percentage': commissionPercentage,
      'commission_amount': commissionAmount,
      'bonus_amount': bonusAmount,
      'total_commission': totalCommission,
      'status': status,
      'payment_date': paymentDate,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'notes': notes,
      'approved_at': approvedAt,
      'paid_at': paidAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Información del proyecto
class ProjectInfo {
  final int id;
  final String name;

  ProjectInfo({
    required this.id,
    required this.name,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Información de la unidad
class UnitInfo {
  final int id;
  final String unitNumber;

  UnitInfo({
    required this.id,
    required this.unitNumber,
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(
      id: json['id'] as int,
      unitNumber: json['unit_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_number': unitNumber,
    };
  }
}

/// Información de la oportunidad
class OpportunityInfo {
  final int id;
  final String clientName;

  OpportunityInfo({
    required this.id,
    required this.clientName,
  });

  factory OpportunityInfo.fromJson(Map<String, dynamic> json) {
    return OpportunityInfo(
      id: json['id'] as int,
      clientName: json['client_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
    };
  }
}

