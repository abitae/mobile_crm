/// Modelo de opciones para formularios de clientes
/// Según documentación API, las opciones vienen como Map<String, String>
class ClientOptions {
  final Map<String, String> documentTypes;
  final Map<String, String> clientTypes;
  final Map<String, String> sources;
  final Map<String, String> statuses;

  ClientOptions({
    required this.documentTypes,
    required this.clientTypes,
    required this.sources,
    required this.statuses,
  });

  factory ClientOptions.fromJson(Map<String, dynamic> json) {
    return ClientOptions(
      documentTypes: json['document_types'] != null
          ? Map<String, String>.from(json['document_types'] as Map)
          : {},
      clientTypes: json['client_types'] != null
          ? Map<String, String>.from(json['client_types'] as Map)
          : {},
      sources: json['sources'] != null
          ? Map<String, String>.from(json['sources'] as Map)
          : {},
      statuses: json['statuses'] != null
          ? Map<String, String>.from(json['statuses'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_types': documentTypes,
      'client_types': clientTypes,
      'sources': sources,
      'statuses': statuses,
    };
  }

  // Getters de conveniencia para obtener listas de claves
  List<String> get documentTypesList => documentTypes.keys.toList();
  List<String> get clientTypesList => clientTypes.keys.toList();
  List<String> get sourcesList => sources.keys.toList();
  List<String> get statusesList => statuses.keys.toList();

  // Getters de conveniencia para obtener etiquetas
  String getDocumentTypeLabel(String key) => documentTypes[key] ?? key;
  String getClientTypeLabel(String key) => clientTypes[key] ?? key;
  String getSourceLabel(String key) => sources[key] ?? key;
  String getStatusLabel(String key) => statuses[key] ?? key;
}

