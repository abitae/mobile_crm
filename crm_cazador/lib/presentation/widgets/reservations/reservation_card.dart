import 'package:flutter/material.dart';
import '../../../data/models/reservation_model.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar una tarjeta de reserva
class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
              // Header: Número de reserva y estados
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.reservationNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  _buildStatusChip(context, reservation.status),
                  const SizedBox(width: 6),
                  _buildPaymentStatusChip(context, reservation.paymentStatus),
                ],
              ),
              const SizedBox(height: 12),
              
              // Información del cliente
              if (reservation.client != null) ...[
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reservation.client!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Información del proyecto y unidad
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reservation.project?.name ?? 'Proyecto ${reservation.projectId}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (reservation.unit != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.home_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getUnitIdentifier(reservation.unit!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                if (reservation.unit!.unitManzana != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Manzana: ${reservation.unit!.unitManzana}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Precios de la unidad
                if (reservation.unit!.basePrice != null || 
                    reservation.unit!.totalPrice != null || 
                    reservation.unit!.finalPrice != null) ...[
                  const SizedBox(height: 8),
                  if (reservation.unit!.basePrice != null)
                    Row(
                      children: [
                        Icon(Icons.price_check_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Precio Base: ${currencyFormat.format(reservation.unit!.basePrice!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  if (reservation.unit!.totalPrice != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calculate_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Precio Total: ${currencyFormat.format(reservation.unit!.totalPrice!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (reservation.unit!.finalPrice != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 14, color: Colors.green[700]!),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Precio Final: ${currencyFormat.format(reservation.unit!.finalPrice!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
              const SizedBox(height: 12),
              
              // Fechas y monto
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.calendar_today_outlined,
                      'Reserva',
                      dateFormat.format(reservation.reservationDate),
                    ),
                  ),
                  if (reservation.expirationDate != null)
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.event_outlined,
                        'Vence',
                        dateFormat.format(reservation.expirationDate!),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                context,
                Icons.attach_money,
                'Monto',
                currencyFormat.format(reservation.reservationAmount),
              ),
              
              // Indicador de expiración próxima
              if (reservation.isExpiringSoon && reservation.daysUntilExpiration != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Expira en ${reservation.daysUntilExpiration} días',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
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

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildPaymentStatusChip(BuildContext context, String paymentStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = _getPaymentStatusColorAndLabel(paymentStatus, colorScheme);
    
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
          Icon(Icons.payment, size: 10, color: color),
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
      case 'activa':
        return (Colors.green, 'Activa');
      case 'confirmada':
        return (Colors.blue, 'Confirmada');
      case 'cancelada':
        return (Colors.red, 'Cancelada');
      case 'vencida':
        return (Colors.grey, 'Vencida');
      case 'convertida_venta':
        return (Colors.purple, 'Convertida');
      default:
        return (colorScheme.onSurfaceVariant, status);
    }
  }

  (Color, String) _getPaymentStatusColorAndLabel(String paymentStatus, ColorScheme colorScheme) {
    switch (paymentStatus.toLowerCase()) {
      case 'pagado':
        return (Colors.green, 'Pagado');
      case 'pendiente':
        return (Colors.orange, 'Pendiente');
      case 'parcial':
        return (Colors.blue, 'Parcial');
      default:
        return (colorScheme.onSurfaceVariant, paymentStatus);
    }
  }

  String _getUnitIdentifier(ReservationUnit unit) {
    if (unit.fullIdentifier != null) {
      return unit.fullIdentifier!;
    }
    if (unit.unitManzana != null) {
      return 'Mz. ${unit.unitManzana} • ${unit.unitNumber}';
    }
    return unit.unitNumber;
  }
}

