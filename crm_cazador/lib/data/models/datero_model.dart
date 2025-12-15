/// Modelo de Datero para Cazador
class DateroModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String dni;
  final String? pin; // solo se usa al crear/actualizar si se envía
  final String? ocupacion;
  final String? banco;
  final String? cuentaBancaria;
  final String? cciBancaria;
  final bool isActive;
  final Map<String, dynamic>? lider;

  DateroModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dni,
    this.pin,
    this.ocupacion,
    this.banco,
    this.cuentaBancaria,
    this.cciBancaria,
    this.isActive = true,
    this.lider,
  });

  factory DateroModel.fromJson(Map<String, dynamic> json) {
    return DateroModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      ocupacion: json['ocupacion'] as String?,
      banco: json['banco'] as String?,
      cuentaBancaria: json['cuenta_bancaria'] as String?,
      cciBancaria: json['cci_bancaria'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lider: json['lider'] as Map<String, dynamic>?,
    );
  }

  /// Payload para creación
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dni': dni,
      if (pin != null && pin!.isNotEmpty) 'pin': pin,
      if (ocupacion != null && ocupacion!.isNotEmpty) 'ocupacion': ocupacion,
      if (banco != null && banco!.isNotEmpty) 'banco': banco,
      if (cuentaBancaria != null && cuentaBancaria!.isNotEmpty)
        'cuenta_bancaria': cuentaBancaria,
      if (cciBancaria != null && cciBancaria!.isNotEmpty)
        'cci_bancaria': cciBancaria,
    };
  }

  /// Payload para actualización parcial
  Map<String, dynamic> toPartialJson() {
    final map = <String, dynamic>{};

    if (name.isNotEmpty) map['name'] = name;
    if (email.isNotEmpty) map['email'] = email;
    if (phone.isNotEmpty) map['phone'] = phone;
    if (dni.isNotEmpty) map['dni'] = dni;
    if (pin != null && pin!.isNotEmpty) map['pin'] = pin;
    if (ocupacion != null && ocupacion!.isNotEmpty) map['ocupacion'] = ocupacion;
    if (banco != null && banco!.isNotEmpty) map['banco'] = banco;
    if (cuentaBancaria != null && cuentaBancaria!.isNotEmpty) {
      map['cuenta_bancaria'] = cuentaBancaria;
    }
    if (cciBancaria != null && cciBancaria!.isNotEmpty) {
      map['cci_bancaria'] = cciBancaria;
    }
    map['is_active'] = isActive;

    return map;
  }

  DateroModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? dni,
    String? pin,
    String? ocupacion,
    String? banco,
    String? cuentaBancaria,
    String? cciBancaria,
    bool? isActive,
    Map<String, dynamic>? lider,
  }) {
    return DateroModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dni: dni ?? this.dni,
      pin: pin ?? this.pin,
      ocupacion: ocupacion ?? this.ocupacion,
      banco: banco ?? this.banco,
      cuentaBancaria: cuentaBancaria ?? this.cuentaBancaria,
      cciBancaria: cciBancaria ?? this.cciBancaria,
      isActive: isActive ?? this.isActive,
      lider: lider ?? this.lider,
    );
  }
}


