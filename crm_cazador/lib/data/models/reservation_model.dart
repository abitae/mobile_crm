/// Modelo de reserva para Cazador
class ReservationModel {
  final int id;
  final String reservationNumber;
  final int clientId;
  final int projectId;
  final int unitId;
  final int advisorId;
  final String reservationType;
  final String status;
  final DateTime reservationDate;
  final DateTime? expirationDate;
  final double reservationAmount;
  final double? reservationPercentage;
  final String? paymentMethod;
  final String paymentStatus;
  final String? paymentReference;
  final String? notes;
  final String? termsConditions;
  final String? image;
  final String? imageUrl;
  final bool clientSignature;
  final bool advisorSignature;
  final bool isActive;
  final bool isConfirmed;
  final bool isCancelled;
  final bool isExpired;
  final bool isConverted;
  final bool isExpiringSoon;
  final int? daysUntilExpiration;
  final String? statusColor;
  final String? paymentStatusColor;
  final String? formattedReservationAmount;
  final String? formattedReservationPercentage;
  final bool canBeConfirmed;
  final bool canBeCancelled;
  final bool canBeConverted;
  final ReservationClient? client;
  final ReservationProject? project;
  final ReservationUnit? unit;
  final ReservationAdvisor? advisor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationModel({
    required this.id,
    required this.reservationNumber,
    required this.clientId,
    required this.projectId,
    required this.unitId,
    required this.advisorId,
    required this.reservationType,
    required this.status,
    required this.reservationDate,
    this.expirationDate,
    required this.reservationAmount,
    this.reservationPercentage,
    this.paymentMethod,
    required this.paymentStatus,
    this.paymentReference,
    this.notes,
    this.termsConditions,
    this.image,
    this.imageUrl,
    this.clientSignature = false,
    this.advisorSignature = false,
    this.isActive = true,
    this.isConfirmed = false,
    this.isCancelled = false,
    this.isExpired = false,
    this.isConverted = false,
    this.isExpiringSoon = false,
    this.daysUntilExpiration,
    this.statusColor,
    this.paymentStatusColor,
    this.formattedReservationAmount,
    this.formattedReservationPercentage,
    this.canBeConfirmed = false,
    this.canBeCancelled = false,
    this.canBeConverted = false,
    this.client,
    this.project,
    this.unit,
    this.advisor,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para parsear fechas de forma segura
    // Según la documentación:
    // - reservation_date y expiration_date: formato "YYYY-MM-DD" (ej: "2024-01-15")
    // - created_at y updated_at: formato "YYYY-MM-DD HH:MM:SS" (ej: "2024-01-15 10:00:00")
    DateTime? _parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      try {
        final dateStr = dateValue.toString().trim();
        if (dateStr.isEmpty) return null;
        
        // Intentar parsear directamente (DateTime.parse maneja ambos formatos)
        try {
          return DateTime.parse(dateStr);
        } catch (_) {
          // Si falla, intentar extraer solo la parte de fecha (YYYY-MM-DD)
          if (dateStr.length >= 10) {
            final dateOnly = dateStr.substring(0, 10);
            return DateTime.parse(dateOnly);
          }
          return null;
        }
      } catch (e) {
        print('⚠️ [ReservationModel] Error al parsear fecha: $dateValue - $e');
        return null;
      }
    }

    // Función auxiliar para parsear objetos anidados de forma segura
    T? _parseNested<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
      if (value == null) return null;
      if (value is! Map<String, dynamic>) return null;
      try {
        return fromJson(value);
      } catch (e) {
        print('⚠️ [ReservationModel] Error al parsear objeto anidado: $e');
        return null;
      }
    }

    return ReservationModel(
      id: json['id'] as int? ?? 0,
      reservationNumber: json['reservation_number'] as String? ?? '',
      clientId: json['client_id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      unitId: json['unit_id'] as int? ?? 0,
      advisorId: json['advisor_id'] as int? ?? 0,
      reservationType: json['reservation_type'] as String? ?? 'pre_reserva',
      status: json['status'] as String? ?? 'activa',
      reservationDate: _parseDate(json['reservation_date']) ?? DateTime.now(),
      expirationDate: _parseDate(json['expiration_date']),
      reservationAmount: (json['reservation_amount'] as num?)?.toDouble() ?? 0.0,
      reservationPercentage: json['reservation_percentage'] != null
          ? (json['reservation_percentage'] as num).toDouble()
          : null,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pendiente',
      paymentReference: json['payment_reference'] as String?,
      notes: json['notes'] as String?,
      termsConditions: json['terms_conditions'] as String?,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      clientSignature: json['client_signature'] as bool? ?? false,
      advisorSignature: json['advisor_signature'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isConfirmed: json['is_confirmed'] as bool? ?? false,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
      isConverted: json['is_converted'] as bool? ?? false,
      isExpiringSoon: json['is_expiring_soon'] as bool? ?? false,
      daysUntilExpiration: json['days_until_expiration'] as int?,
      statusColor: json['status_color'] as String?,
      paymentStatusColor: json['payment_status_color'] as String?,
      formattedReservationAmount: json['formatted_reservation_amount'] as String?,
      formattedReservationPercentage: json['formatted_reservation_percentage'] as String?,
      canBeConfirmed: json['can_be_confirmed'] as bool? ?? false,
      canBeCancelled: json['can_be_cancelled'] as bool? ?? false,
      canBeConverted: json['can_be_converted'] as bool? ?? false,
      client: _parseNested(json['client'], ReservationClient.fromJson),
      project: _parseNested(json['project'], ReservationProject.fromJson),
      unit: _parseNested(json['unit'], ReservationUnit.fromJson),
      advisor: _parseNested(json['advisor'], ReservationAdvisor.fromJson),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_number': reservationNumber,
      'client_id': clientId,
      'project_id': projectId,
      'unit_id': unitId,
      'advisor_id': advisorId,
      'reservation_type': reservationType,
      'status': status,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      'expiration_date': expirationDate?.toIso8601String().split('T')[0],
      'reservation_amount': reservationAmount,
      'reservation_percentage': reservationPercentage,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_reference': paymentReference,
      'notes': notes,
      'terms_conditions': termsConditions,
      'image': image,
      'image_url': imageUrl,
      'client_signature': clientSignature,
      'advisor_signature': advisorSignature,
      'is_active': isActive,
      'is_confirmed': isConfirmed,
      'is_cancelled': isCancelled,
      'is_expired': isExpired,
      'is_converted': isConverted,
      'is_expiring_soon': isExpiringSoon,
      'days_until_expiration': daysUntilExpiration,
      'status_color': statusColor,
      'payment_status_color': paymentStatusColor,
      'formatted_reservation_amount': formattedReservationAmount,
      'formatted_reservation_percentage': formattedReservationPercentage,
      'can_be_confirmed': canBeConfirmed,
      'can_be_cancelled': canBeCancelled,
      'can_be_converted': canBeConverted,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'client_id': clientId,
      'project_id': projectId,
      'unit_id': unitId,
      'advisor_id': advisorId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      if (expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String().split('T')[0],
      'reservation_amount': reservationAmount,
      if (reservationPercentage != null)
        'reservation_percentage': reservationPercentage,
      if (paymentMethod != null && paymentMethod!.isNotEmpty)
        'payment_method': paymentMethod,
      if (paymentReference != null && paymentReference!.isNotEmpty)
        'payment_reference': paymentReference,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (termsConditions != null && termsConditions!.isNotEmpty)
        'terms_conditions': termsConditions,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};
    if (clientId > 0) map['client_id'] = clientId;
    if (advisorId > 0) map['advisor_id'] = advisorId;
    map['reservation_date'] = reservationDate.toIso8601String().split('T')[0];
    if (expirationDate != null) {
      map['expiration_date'] = expirationDate!.toIso8601String().split('T')[0];
    }
    map['reservation_amount'] = reservationAmount;
    if (reservationPercentage != null) {
      map['reservation_percentage'] = reservationPercentage;
    }
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      map['payment_method'] = paymentMethod;
    }
    if (paymentStatus.isNotEmpty) {
      map['payment_status'] = paymentStatus;
    }
    if (paymentReference != null && paymentReference!.isNotEmpty) {
      map['payment_reference'] = paymentReference;
    }
    if (notes != null && notes!.isNotEmpty) {
      map['notes'] = notes;
    }
    if (termsConditions != null && termsConditions!.isNotEmpty) {
      map['terms_conditions'] = termsConditions;
    }
    return map;
  }

  Map<String, dynamic> toConfirmJson() {
    final map = <String, dynamic>{};
    map['reservation_date'] = reservationDate.toIso8601String().split('T')[0];
    if (expirationDate != null) {
      map['expiration_date'] = expirationDate!.toIso8601String().split('T')[0];
    }
    map['reservation_amount'] = reservationAmount;
    if (reservationPercentage != null) {
      map['reservation_percentage'] = reservationPercentage;
    }
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      map['payment_method'] = paymentMethod;
    }
    if (paymentStatus.isNotEmpty) {
      map['payment_status'] = paymentStatus;
    }
    if (paymentReference != null && paymentReference!.isNotEmpty) {
      map['payment_reference'] = paymentReference;
    }
    return map;
  }

  Map<String, dynamic> toCancelJson() {
    return {
      'cancel_note': notes ?? '',
    };
  }
}

/// Cliente asociado a la reserva
class ReservationClient {
  final int id;
  final String name;
  final String? phone;
  final String? documentType;
  final String? documentNumber;

  ReservationClient({
    required this.id,
    required this.name,
    this.phone,
    this.documentType,
    this.documentNumber,
  });

  factory ReservationClient.fromJson(Map<String, dynamic> json) {
    return ReservationClient(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      documentType: json['document_type'] as String?,
      documentNumber: json['document_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'document_type': documentType,
      'document_number': documentNumber,
    };
  }
}

/// Proyecto asociado a la reserva
class ReservationProject {
  final int id;
  final String name;
  final String? address;
  final String? district;
  final String? province;

  ReservationProject({
    required this.id,
    required this.name,
    this.address,
    this.district,
    this.province,
  });

  factory ReservationProject.fromJson(Map<String, dynamic> json) {
    return ReservationProject(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'district': district,
      'province': province,
    };
  }
}

/// Unidad asociada a la reserva
class ReservationUnit {
  final int id;
  final String? unitManzana;
  final String unitNumber;
  final String? fullIdentifier;
  final double? area;
  final double? finalPrice;

  ReservationUnit({
    required this.id,
    this.unitManzana,
    required this.unitNumber,
    this.fullIdentifier,
    this.area,
    this.finalPrice,
  });

  factory ReservationUnit.fromJson(Map<String, dynamic> json) {
    return ReservationUnit(
      id: json['id'] as int? ?? 0,
      unitManzana: json['unit_manzana'] as String?,
      unitNumber: json['unit_number'] as String? ?? '',
      fullIdentifier: json['full_identifier'] as String?,
      area: json['area'] != null ? (json['area'] as num).toDouble() : null,
      finalPrice: json['final_price'] != null
          ? (json['final_price'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_manzana': unitManzana,
      'unit_number': unitNumber,
      'full_identifier': fullIdentifier,
      'area': area,
      'final_price': finalPrice,
    };
  }
}

/// Asesor asociado a la reserva
class ReservationAdvisor {
  final int id;
  final String name;
  final String? email;

  ReservationAdvisor({
    required this.id,
    required this.name,
    this.email,
  });

  factory ReservationAdvisor.fromJson(Map<String, dynamic> json) {
    return ReservationAdvisor(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

