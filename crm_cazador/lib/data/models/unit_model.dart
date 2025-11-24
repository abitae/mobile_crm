/// Modelo de unidad inmobiliaria (lote, departamento, casa, etc.)
class UnitModel {
  final int id;
  final int projectId;
  final String? unitManzana;
  final String unitNumber;
  final String unitType; // lote, departamento, casa, etc.
  final double area;
  final String status; // disponible, reservado, vendido, bloqueado
  final double basePrice;
  final double finalPrice;
  final double? pricePerSquareMeter;
  final bool isAvailable;
  final int? bedrooms;
  final int? bathrooms;
  final int? parkingSpots;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UnitModel({
    required this.id,
    required this.projectId,
    this.unitManzana,
    required this.unitNumber,
    required this.unitType,
    required this.area,
    required this.status,
    required this.basePrice,
    required this.finalPrice,
    this.pricePerSquareMeter,
    required this.isAvailable,
    this.bedrooms,
    this.bathrooms,
    this.parkingSpots,
    this.description,
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
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0.0,
      pricePerSquareMeter: (json['price_per_square_meter'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      parkingSpots: json['parking_spots'] as int?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

