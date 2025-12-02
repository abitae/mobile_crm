/// Modelo de usuario
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? dni;
  final String? role;
  final bool? isActive;
  final String? banco;
  final String? cuentaBancaria;
  final String? cciBancaria;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dni,
    this.role,
    this.isActive,
    this.banco,
    this.cuentaBancaria,
    this.cciBancaria,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dni: json['dni'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] as bool?,
      banco: json['banco'] as String?,
      cuentaBancaria: json['cuenta_bancaria'] as String?,
      cciBancaria: json['cci_bancaria'] as String?,
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
      'email': email,
      'phone': phone,
      'dni': dni,
      'role': role,
      'is_active': isActive,
      'banco': banco,
      'cuenta_bancaria': cuentaBancaria,
      'cci_bancaria': cciBancaria,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isDatero => role?.toLowerCase() == 'datero';
}

