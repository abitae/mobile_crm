import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/unit_model.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../providers/project_provider.dart';

/// Wrapper para obtener la unidad del provider y mostrar el detalle
class UnitDetailScreenWrapper extends ConsumerWidget {
  final int projectId;
  final int unitId;

  const UnitDetailScreenWrapper({
    super.key,
    required this.projectId,
    required this.unitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsNotifier = ref.watch(projectUnitsNotifierProvider(projectId));
    final state = unitsNotifier.currentState;

    // Buscar la unidad en la lista cargada
    final unit = state.units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => throw Exception('Unidad no encontrada'),
    );

    if (state.isLoading && state.units.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Unidad')),
        body: const LoadingIndicator(),
      );
    }

    if (state.error != null && state.units.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Unidad')),
        body: AppErrorWidget(
          message: state.error!,
          onRetry: () {
            unitsNotifier.loadUnits(refresh: true);
          },
        ),
      );
    }

    try {
      return UnitDetailScreen(
        unit: unit,
        projectId: projectId,
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Unidad')),
        body: AppErrorWidget(
          message: 'Unidad no encontrada: $e',
          onRetry: () {
            unitsNotifier.loadUnits(refresh: true);
          },
        ),
      );
    }
  }
}

/// Pantalla de detalle de unidad
class UnitDetailScreen extends ConsumerWidget {
  final UnitModel unit;
  final int projectId;

  const UnitDetailScreen({
    super.key,
    required this.unit,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_getUnitTitle()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con identificador y estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getUnitIdentifier(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(context, unit.status),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getUnitTypeIcon(unit.unitType),
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Información básica
            _buildSectionHeader(context, 'Información Básica', Icons.info_outline),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('Tipo', _getUnitTypeLabel(unit.unitType)),
                    if (unit.unitManzana != null)
                      _buildInfoRow('Manzana', unit.unitManzana!),
                    _buildInfoRow('Número', unit.unitNumber),
                    if (unit.fullIdentifier != null)
                      _buildInfoRow('Identificador Completo', unit.fullIdentifier!),
                    if (unit.floor != null)
                      _buildInfoRow('Piso', unit.floor.toString()),
                    if (unit.tower != null)
                      _buildInfoRow('Torre', unit.tower!),
                    if (unit.block != null)
                      _buildInfoRow('Bloque', unit.block!),
                    _buildInfoRow('Área', '${unit.area.toStringAsFixed(0)} m²'),
                    if (unit.totalArea != null)
                      _buildInfoRow('Área Total', '${unit.totalArea!.toStringAsFixed(0)} m²'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Características
            if (unit.bedrooms != null ||
                unit.bathrooms != null ||
                unit.parkingSpaces != null ||
                unit.storageRooms != null ||
                unit.balconyArea != null ||
                unit.terraceArea != null ||
                unit.gardenArea != null) ...[
              _buildSectionHeader(context, 'Características', Icons.home_outlined),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (unit.bedrooms != null && unit.bedrooms! > 0)
                        _buildFeatureChip(context, '${unit.bedrooms} Dorm.', Icons.bed),
                      if (unit.bathrooms != null && unit.bathrooms! > 0)
                        _buildFeatureChip(context, '${unit.bathrooms} Baños', Icons.bathtub_outlined),
                      if (unit.parkingSpaces != null && unit.parkingSpaces! > 0)
                        _buildFeatureChip(context, '${unit.parkingSpaces} Estac.', Icons.local_parking),
                      if (unit.storageRooms != null && unit.storageRooms! > 0)
                        _buildFeatureChip(context, '${unit.storageRooms} Depós.', Icons.inventory_2_outlined),
                      if (unit.gardenArea != null && unit.gardenArea! > 0)
                        _buildFeatureChip(context, 'Jardín ${unit.gardenArea!.toStringAsFixed(0)}m²', Icons.grass),
                      if (unit.balconyArea != null && unit.balconyArea! > 0)
                        _buildFeatureChip(context, 'Balcón ${unit.balconyArea!.toStringAsFixed(0)}m²', Icons.balcony),
                      if (unit.terraceArea != null && unit.terraceArea! > 0)
                        _buildFeatureChip(context, 'Terraza ${unit.terraceArea!.toStringAsFixed(0)}m²', Icons.deck),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Precios
            _buildSectionHeader(context, 'Información de Precios', Icons.attach_money),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPriceRow(
                      context,
                      'Precio Final',
                      currencyFormat.format(unit.finalPrice),
                      colorScheme.primary,
                      isHighlight: true,
                    ),
                    if (unit.basePrice != null) ...[
                      const Divider(),
                      _buildPriceRow(
                        context,
                        'Precio Base',
                        currencyFormat.format(unit.basePrice!),
                        colorScheme.onSurfaceVariant,
                      ),
                    ],
                    if (unit.totalPrice != null) ...[
                      const Divider(),
                      _buildPriceRow(
                        context,
                        'Precio Total',
                        currencyFormat.format(unit.totalPrice!),
                        colorScheme.onSurfaceVariant,
                      ),
                    ],
                    if (unit.pricePerSquareMeter != null) ...[
                      const Divider(),
                      _buildPriceRow(
                        context,
                        'Precio por m²',
                        currencyFormat.format(unit.pricePerSquareMeter!),
                        colorScheme.onSurfaceVariant,
                      ),
                    ],
                    if (unit.discountPercentage != null && unit.discountPercentage! > 0) ...[
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_offer, size: 20, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Descuento ${unit.discountPercentage!.toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (unit.discountAmount != null)
                              Text(
                                'Ahorro: ${currencyFormat.format(unit.discountAmount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (unit.commissionPercentage != null || unit.commissionAmount != null) ...[
                      const Divider(),
                      if (unit.commissionPercentage != null)
                        _buildPriceRow(
                          context,
                          'Comisión',
                          '${unit.commissionPercentage!.toStringAsFixed(2)}%',
                          colorScheme.secondary,
                        ),
                      if (unit.commissionAmount != null)
                        _buildPriceRow(
                          context,
                          'Monto Comisión',
                          currencyFormat.format(unit.commissionAmount!),
                          colorScheme.secondary,
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estado y bloqueo
            if (unit.isBlocked || unit.blockedUntil != null || unit.blockedReason != null) ...[
              _buildSectionHeader(context, 'Estado', Icons.info_outline),
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.block, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Unidad Bloqueada',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (unit.blockedUntil != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Bloqueada hasta: ${dateFormat.format(unit.blockedUntil!)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (unit.blockedReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Razón: ${unit.blockedReason}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notas
            if (unit.notes != null && unit.notes!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Notas', Icons.note_outlined),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    unit.notes!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón para crear reserva
            if (unit.isAvailable && !unit.isBlocked)
              FilledButton.icon(
                onPressed: () {
                  context.push('/reservations/new?projectId=${unit.projectId}&unitId=${unit.id}');
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Crear Reserva'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getUnitTitle() {
    if (unit.fullIdentifier != null) {
      return 'Unidad ${unit.fullIdentifier}';
    }
    if (unit.unitManzana != null) {
      return 'Mz. ${unit.unitManzana} • N° ${unit.unitNumber}';
    }
    return 'Unidad N° ${unit.unitNumber}';
  }

  String _getUnitIdentifier() {
    if (unit.fullIdentifier != null) {
      return unit.fullIdentifier!;
    }
    if (unit.unitManzana != null) {
      return 'Mz. ${unit.unitManzana} • N° ${unit.unitNumber}';
    }
    return 'N° ${unit.unitNumber}';
  }

  String _getUnitTypeLabel(String type) {
    final labels = {
      'lote': 'Lote',
      'departamento': 'Departamento',
      'casa': 'Casa',
      'oficina': 'Oficina',
      'local': 'Local',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  IconData _getUnitTypeIcon(String type) {
    final icons = {
      'lote': Icons.landscape,
      'departamento': Icons.apartment,
      'casa': Icons.home,
      'oficina': Icons.business,
      'local': Icons.store,
    };
    return icons[type.toLowerCase()] ?? Icons.home;
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (color, label) = _getStatusColorAndLabel(status, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _getStatusColorAndLabel(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'disponible':
        return (Colors.green, 'Disponible');
      case 'reservado':
        return (Colors.orange, 'Reservado');
      case 'vendido':
        return (Colors.blue, 'Vendido');
      case 'bloqueado':
        return (Colors.red, 'Bloqueado');
      default:
        return (colorScheme.onSurfaceVariant, status);
    }
  }
}
