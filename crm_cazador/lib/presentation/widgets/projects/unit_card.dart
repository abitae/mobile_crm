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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Manzana y número en horizontal
              Row(
                children: [
                  // Manzana y número destacados horizontalmente
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unit.unitManzana != null) ...[
                          Text(
                            'Mz. ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            unit.unitManzana!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'N° ${unit.unitNumber}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Tipo y estado
                  _buildCompactChip(
                    context,
                    _getUnitTypeLabel(unit.unitType),
                    colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  _buildStatusChip(context, unit.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Información del lote con etiquetas
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledInfo(
                      context,
                      'Área',
                      '${unit.area.toStringAsFixed(0)} m²',
                      Icons.square_foot,
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLabeledInfo(
                      context,
                      'Precio Final',
                      currencyFormat.format(unit.finalPrice),
                      Icons.attach_money,
                      Colors.green[700]!,
                    ),
                  ),
                ],
              ),
              
              // Precios base y total (si están disponibles)
              if (unit.basePrice != null || unit.totalPrice != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (unit.basePrice != null)
                      Expanded(
                        child: _buildLabeledInfo(
                          context,
                          'Precio Base',
                          currencyFormat.format(unit.basePrice!),
                          Icons.price_check,
                          colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (unit.basePrice != null && unit.totalPrice != null)
                      const SizedBox(width: 8),
                    if (unit.totalPrice != null)
                      Expanded(
                        child: _buildLabeledInfo(
                          context,
                          'Precio Total',
                          currencyFormat.format(unit.totalPrice!),
                          Icons.calculate,
                          colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
              
              // Características - siempre mostrar si hay datos
              if (unit.bedrooms != null || 
                  unit.bathrooms != null || 
                  unit.parkingSpaces != null ||
                  unit.storageRooms != null ||
                  unit.gardenArea != null ||
                  unit.balconyArea != null ||
                  unit.terraceArea != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Características:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (unit.bedrooms != null && unit.bedrooms! > 0)
                      _buildMiniFeature(context, '${unit.bedrooms} Dorm.', Icons.bed),
                    if (unit.bathrooms != null && unit.bathrooms! > 0)
                      _buildMiniFeature(context, '${unit.bathrooms} Baños', Icons.bathtub_outlined),
                    if (unit.parkingSpaces != null && unit.parkingSpaces! > 0)
                      _buildMiniFeature(context, '${unit.parkingSpaces} Estac.', Icons.local_parking),
                    if (unit.storageRooms != null && unit.storageRooms! > 0)
                      _buildMiniFeature(context, '${unit.storageRooms} Depós.', Icons.inventory_2_outlined),
                    if (unit.gardenArea != null && unit.gardenArea! > 0)
                      _buildMiniFeature(context, 'Jardín ${unit.gardenArea!.toStringAsFixed(0)}m²', Icons.grass),
                    if (unit.balconyArea != null && unit.balconyArea! > 0)
                      _buildMiniFeature(context, 'Balcón ${unit.balconyArea!.toStringAsFixed(0)}m²', Icons.balcony),
                    if (unit.terraceArea != null && unit.terraceArea! > 0)
                      _buildMiniFeature(context, 'Terraza ${unit.terraceArea!.toStringAsFixed(0)}m²', Icons.deck),
                  ],
                ),
              ],
              
              // Descuento - siempre mostrar si hay datos
              if (unit.discountPercentage != null && unit.discountPercentage! > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Descuento ${unit.discountPercentage!.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (unit.discountAmount != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Ahorro: ${currencyFormat.format(unit.discountAmount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green[700],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildLabeledInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  Widget _buildMiniFeature(BuildContext context, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = _getStatusColorAndLabel(status, colorScheme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
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

