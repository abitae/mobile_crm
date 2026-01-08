import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeletons/reservation_detail_skeleton.dart';
import '../../../data/services/reservation_service.dart';
import '../../../core/exceptions/api_exception.dart';
import 'reservation_cancel_dialog.dart';

/// Pantalla de detalle de reserva
class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({
    super.key,
    required this.reservationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(reservationProvider(reservationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Reserva'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: reservationAsync.when(
              data: (reservation) => reservation.status == 'activa'
                  ? () => context.push('/reservations/${reservation.id}/edit')
                  : null,
              loading: () => null,
              error: (_, __) => null,
            ),
            tooltip: 'Editar',
          ),
        ],
      ),
      body: reservationAsync.when(
        data: (reservation) => _buildReservationDetail(context, ref, reservation),
        loading: () => const ReservationDetailSkeleton(),
        error: (error, stackTrace) => AppErrorWidget(
          message: error is ApiException
              ? error.message
              : 'Error al cargar reserva: ${error.toString()}',
          onRetry: () {
            ref.invalidate(reservationProvider(reservationId));
          },
        ),
      ),
    );
  }

  Widget _buildReservationDetail(
    BuildContext context,
    WidgetRef ref,
    reservation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de reserva y estados
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.reservationNumber,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusChip(context, reservation.status),
                      const SizedBox(width: 8),
                      _buildPaymentStatusChip(context, reservation.paymentStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información del Cliente
          if (reservation.client != null) ...[
            _buildSectionHeader(context, 'Cliente', Icons.person_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre', reservation.client!.name),
                    if (reservation.client!.phone != null)
                      _buildInfoRow('Teléfono', reservation.client!.phone!),
                    if (reservation.client!.documentNumber != null)
                      _buildInfoRow(
                        'Documento',
                        '${reservation.client!.documentType ?? 'DNI'}: ${reservation.client!.documentNumber}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Información del Proyecto
          if (reservation.project != null) ...[
            _buildSectionHeader(context, 'Proyecto', Icons.business_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre', reservation.project!.name),
                    if (reservation.project!.address != null)
                      _buildInfoRow('Dirección', reservation.project!.address!),
                    if (reservation.project!.district != null)
                      _buildInfoRow('Distrito', reservation.project!.district!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Información de la Unidad
          if (reservation.unit != null) ...[
            _buildSectionHeader(context, 'Unidad', Icons.home_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reservation.unit!.unitManzana != null)
                      _buildInfoRow(
                        'Manzana',
                        reservation.unit!.unitManzana!,
                      ),
                    _buildInfoRow(
                      'Número',
                      reservation.unit!.unitNumber,
                    ),
                    if (reservation.unit!.fullIdentifier != null)
                      _buildInfoRow(
                        'Identificador Completo',
                        reservation.unit!.fullIdentifier!,
                      ),
                    if (reservation.unit!.area != null)
                      _buildInfoRow(
                        'Área',
                        '${reservation.unit!.area!.toStringAsFixed(0)} m²',
                      ),
                    if (reservation.unit!.basePrice != null)
                      _buildInfoRow(
                        'Precio Base',
                        currencyFormat.format(reservation.unit!.basePrice!),
                      ),
                    if (reservation.unit!.totalPrice != null)
                      _buildInfoRow(
                        'Precio Total',
                        currencyFormat.format(reservation.unit!.totalPrice!),
                      ),
                    if (reservation.unit!.finalPrice != null)
                      _buildInfoRow(
                        'Precio Final',
                        currencyFormat.format(reservation.unit!.finalPrice!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Información de la Reserva
          _buildSectionHeader(context, 'Información de Reserva', Icons.info_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Fecha de Reserva',
                    dateFormat.format(reservation.reservationDate),
                  ),
                  if (reservation.expirationDate != null)
                    _buildInfoRow(
                      'Fecha de Vencimiento',
                      dateFormat.format(reservation.expirationDate!),
                    ),
                  if (reservation.daysUntilExpiration != null)
                    _buildInfoRow(
                      'Días hasta vencimiento',
                      '${reservation.daysUntilExpiration} días',
                    ),
                  _buildInfoRow(
                    'Monto de Reserva',
                    currencyFormat.format(reservation.reservationAmount),
                  ),
                  if (reservation.paymentMethod != null)
                    _buildInfoRow('Método de Pago', reservation.paymentMethod!),
                  if (reservation.paymentReference != null)
                    _buildInfoRow(
                      'Referencia de Pago',
                      reservation.paymentReference!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Imagen del comprobante
          if (reservation.imageUrl != null) ...[
            _buildSectionHeader(context, 'Comprobante de Pago', Icons.image_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CachedNetworkImage(
                  imageUrl: reservation.imageUrl!,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notas
          if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
            _buildSectionHeader(context, 'Notas', Icons.note_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  reservation.notes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Acciones según estado
          _buildActions(context, ref, reservation),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildPaymentStatusChip(BuildContext context, String paymentStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = _getPaymentStatusColorAndLabel(paymentStatus, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 14, color: color),
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

  (Color, String) _getPaymentStatusColorAndLabel(
      String paymentStatus, ColorScheme colorScheme) {
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

  Widget _buildActions(BuildContext context, WidgetRef ref, reservation) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (reservation.status == 'activa') ...[
              FilledButton.icon(
                onPressed: () {
                  context.push('/reservations/${reservation.id}/confirm');
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar Reserva'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _showCancelDialog(context, ref, reservation);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar Reserva'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ] else if (reservation.status == 'confirmada') ...[
              FilledButton.icon(
                onPressed: () {
                  _convertToSale(context, ref, reservation);
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Convertir a Venta'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _showCancelDialog(context, ref, reservation);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar Reserva'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ] else
              Text(
                'No hay acciones disponibles para este estado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, reservation) {
    showDialog(
      context: context,
      builder: (context) => ReservationCancelDialog(
        reservationId: reservation.id,
        onCanceled: () {
          ref.invalidate(reservationProvider(reservation.id));
          ref.read(reservationsNotifierProvider).refreshReservations();
        },
      ),
    );
  }

  Future<void> _convertToSale(BuildContext context, WidgetRef ref, reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convertir a Venta'),
        content: const Text(
          '¿Estás seguro de convertir esta reserva a una venta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Convertir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReservationService.convertToSale(reservation.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva convertida a venta exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(reservationProvider(reservation.id));
          ref.read(reservationsNotifierProvider).refreshReservations();
          if (context.mounted) {
            context.pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e is ApiException ? e.message : 'Error al convertir reserva',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

