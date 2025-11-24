/// Modelo de proyecto inmobiliario
class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final String projectType; // lotes, casas, departamentos, oficinas, mixto
  final bool isPublished;
  final String? loteType; // normal, express
  final String? stage; // preventa, lanzamiento, venta_activa, cierre
  final String? legalStatus; // con_titulo, en_tramite, habilitado
  final String? estadoLegal;
  final String? tipoProyecto; // propio, tercero
  final String? tipoFinanciamiento; // contado, financiado
  final String? banco;
  final String? tipoCuenta;
  final String? cuentaBancaria;
  final String? address;
  final String? district;
  final String? province;
  final String? region;
  final String? country;
  final String? ubicacion; // URL Google Maps
  final String? fullAddress;
  final Map<String, double>? coordinates; // {lat, lng}
  final int totalUnits;
  final int availableUnits;
  final int reservedUnits;
  final int soldUnits;
  final int blockedUnits;
  final double progressPercentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deliveryDate;
  final String status; // activo, inactivo, suspendido, finalizado
  final String? pathImagePortada;
  final String? pathVideoPortada;
  final List<Map<String, dynamic>>? pathImages;
  final List<Map<String, dynamic>>? pathVideos;
  final List<Map<String, dynamic>>? pathDocuments;
  final List<Map<String, dynamic>>? advisors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.projectType,
    required this.isPublished,
    this.loteType,
    this.stage,
    this.legalStatus,
    this.estadoLegal,
    this.tipoProyecto,
    this.tipoFinanciamiento,
    this.banco,
    this.tipoCuenta,
    this.cuentaBancaria,
    this.address,
    this.district,
    this.province,
    this.region,
    this.country,
    this.ubicacion,
    this.fullAddress,
    this.coordinates,
    required this.totalUnits,
    required this.availableUnits,
    required this.reservedUnits,
    required this.soldUnits,
    required this.blockedUnits,
    required this.progressPercentage,
    this.startDate,
    this.endDate,
    this.deliveryDate,
    required this.status,
    this.pathImagePortada,
    this.pathVideoPortada,
    this.pathImages,
    this.pathVideos,
    this.pathDocuments,
    this.advisors,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      projectType: json['project_type'] as String,
      isPublished: json['is_published'] as bool? ?? false,
      loteType: json['lote_type'] as String?,
      stage: json['stage'] as String?,
      legalStatus: json['legal_status'] as String?,
      estadoLegal: json['estado_legal'] as String?,
      tipoProyecto: json['tipo_proyecto'] as String?,
      tipoFinanciamiento: json['tipo_financiamiento'] as String?,
      banco: json['banco'] as String?,
      tipoCuenta: json['tipo_cuenta'] as String?,
      cuentaBancaria: json['cuenta_bancaria'] as String?,
      address: json['address'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      ubicacion: json['ubicacion'] as String?,
      fullAddress: json['full_address'] as String?,
      coordinates: json['coordinates'] != null
          ? _parseCoordinates(json['coordinates'] as Map)
          : null,
      totalUnits: json['total_units'] as int? ?? 0,
      availableUnits: json['available_units'] as int? ?? 0,
      reservedUnits: json['reserved_units'] as int? ?? 0,
      soldUnits: json['sold_units'] as int? ?? 0,
      blockedUnits: json['blocked_units'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      status: json['status'] as String,
      pathImagePortada: json['path_image_portada'] as String?,
      pathVideoPortada: json['path_video_portada'] as String?,
      pathImages: json['path_images'] != null
          ? List<Map<String, dynamic>>.from(json['path_images'] as List)
          : null,
      pathVideos: json['path_videos'] != null
          ? List<Map<String, dynamic>>.from(json['path_videos'] as List)
          : null,
      pathDocuments: json['path_documents'] != null
          ? List<Map<String, dynamic>>.from(json['path_documents'] as List)
          : null,
      advisors: json['advisors'] != null
          ? List<Map<String, dynamic>>.from(json['advisors'] as List)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Parsear coordenadas manejando valores null
  static Map<String, double>? _parseCoordinates(Map coordinates) {
    final lat = coordinates['lat'];
    final lng = coordinates['lng'];
    
    // Si ambos son null, retornar null
    if (lat == null && lng == null) {
      return null;
    }
    
    // Si al menos uno tiene valor, crear el mapa
    return {
      if (lat != null) 'lat': (lat as num).toDouble(),
      if (lng != null) 'lng': (lng as num).toDouble(),
    };
  }
}

