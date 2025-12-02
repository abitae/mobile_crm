/// Modelo de estadísticas de comisiones
class CommissionStatsModel {
  final int total;
  final int pendiente;
  final int aprobada;
  final int pagada;
  final int cancelada;
  final double totalPagado;
  final double totalPendiente;
  final double totalMesActual;
  final double totalAnioActual;

  CommissionStatsModel({
    required this.total,
    required this.pendiente,
    required this.aprobada,
    required this.pagada,
    required this.cancelada,
    required this.totalPagado,
    required this.totalPendiente,
    required this.totalMesActual,
    required this.totalAnioActual,
  });

  factory CommissionStatsModel.fromJson(Map<String, dynamic> json) {
    return CommissionStatsModel(
      total: json['total'] as int,
      pendiente: json['pendiente'] as int,
      aprobada: json['aprobada'] as int,
      pagada: json['pagada'] as int,
      cancelada: json['cancelada'] as int,
      totalPagado: (json['total_pagado'] as num).toDouble(),
      totalPendiente: (json['total_pendiente'] as num).toDouble(),
      totalMesActual: (json['total_mes_actual'] as num).toDouble(),
      totalAnioActual: (json['total_anio_actual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pendiente': pendiente,
      'aprobada': aprobada,
      'pagada': pagada,
      'cancelada': cancelada,
      'total_pagado': totalPagado,
      'total_pendiente': totalPendiente,
      'total_mes_actual': totalMesActual,
      'total_anio_actual': totalAnioActual,
    };
  }
}

