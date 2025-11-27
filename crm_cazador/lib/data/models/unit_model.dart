/// Modelo de unidad inmobiliaria (lote, departamento, casa, etc.)
/// 
/// Según la documentación de PROJECTS.md:
/// - Solo se muestran unidades con estado "disponible"
/// - Se ordenan primero por manzana (ascendente) y luego por número de unidad (ascendente)
class UnitModel {
  final int id;
  final int projectId;
  final String? unitManzana;
  final String unitNumber;
  final String unitType; // lote, departamento, casa, etc.
  final int? floor;
  final String? tower;
  final String? block;
  final double area;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpaces;
  final int? storageRooms;
  final double? balconyArea;
  final double? terraceArea;
  final double? gardenArea;
  final double? totalArea;
  final String status; // disponible, reservado, vendido, bloqueado
  final double? basePrice;
  final double? totalPrice;
  final double? discountPercentage;
  final double? discountAmount;
  final double finalPrice;
  final double? pricePerSquareMeter;
  final double? commissionPercentage;
  final double? commissionAmount;
  final DateTime? blockedUntil;
  final String? blockedReason;
  final bool isBlocked;
  final bool isAvailable;
  final String? fullIdentifier;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UnitModel({
    required this.id,
    required this.projectId,
    this.unitManzana,
    required this.unitNumber,
    required this.unitType,
    this.floor,
    this.tower,
    this.block,
    required this.area,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpaces,
    this.storageRooms,
    this.balconyArea,
    this.terraceArea,
    this.gardenArea,
    this.totalArea,
    required this.status,
    this.basePrice,
    this.totalPrice,
    this.discountPercentage,
    this.discountAmount,
    required this.finalPrice,
    this.pricePerSquareMeter,
    this.commissionPercentage,
    this.commissionAmount,
    this.blockedUntil,
    this.blockedReason,
    required this.isBlocked,
    required this.isAvailable,
    this.fullIdentifier,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      unitManzana: json['unit_manzana'] as String?,
      unitNumber: json['unit_number'] as String,
      unitType: json['unit_type'] as String,
      floor: json['floor'] as int?,
      tower: json['tower'] as String?,
      block: json['block'] as String?,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      parkingSpaces: json['parking_spaces'] as int?,
      storageRooms: json['storage_rooms'] as int?,
      balconyArea: (json['balcony_area'] as num?)?.toDouble(),
      terraceArea: (json['terrace_area'] as num?)?.toDouble(),
      gardenArea: (json['garden_area'] as num?)?.toDouble(),
      totalArea: (json['total_area'] as num?)?.toDouble(),
      status: json['status'] as String,
      basePrice: (json['base_price'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0.0,
      pricePerSquareMeter: (json['price_per_square_meter'] as num?)?.toDouble(),
      commissionPercentage: (json['commission_percentage'] as num?)?.toDouble(),
      commissionAmount: (json['commission_amount'] as num?)?.toDouble(),
      blockedUntil: json['blocked_until'] != null
          ? DateTime.parse(json['blocked_until'] as String)
          : null,
      blockedReason: json['blocked_reason'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      fullIdentifier: json['full_identifier'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

