import 'package:flutter/material.dart';
import '../../../data/models/unit_model.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar una tarjeta de unidad
class UnitCard extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback? onTap;

  const UnitCard({
    super.key,
    required this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 0);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con número de unidad y tipo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.unitNumber,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildChip(
                              context,
                              _getUnitTypeLabel(unit.unitType),
                              colorScheme.primary,
                            ),
                            if (unit.unitManzana != null) ...[
                              const SizedBox(width: 8),
                              _buildChip(
                                context,
                                'Mz. ${unit.unitManzana}',
                                colorScheme.secondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, unit.status),
                ],
              ),
              const SizedBox(height: 16),

              // Información principal
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Área',
                      '${unit.area.toStringAsFixed(2)} m²',
                      Icons.square_foot,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Precio',
                      currencyFormat.format(unit.finalPrice),
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              if (unit.pricePerSquareMeter != null) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  context,
                  'Precio/m²',
                  currencyFormat.format(unit.pricePerSquareMeter!),
                  Icons.calculate,
                ),
              ],

              // Características (si aplica)
              if (unit.bedrooms != null || unit.bathrooms != null || unit.parkingSpots != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (unit.bedrooms != null)
                        _buildFeatureChip(
                          context,
                          '${unit.bedrooms}',
                          Icons.bed,
                          'Dorm.',
                        ),
                      if (unit.bathrooms != null)
                        _buildFeatureChip(
                          context,
                          '${unit.bathrooms}',
                          Icons.bathtub_outlined,
                          'Baños',
                        ),
                      if (unit.parkingSpots != null)
                        _buildFeatureChip(
                          context,
                          '${unit.parkingSpots}',
                          Icons.local_parking,
                          'Estac.',
                        ),
                    ],
                  ),
                ),

              // Descripción
              if (unit.description != null && unit.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  unit.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = _getStatusColorAndLabel(status, colorScheme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
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
}

