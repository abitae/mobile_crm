import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/commission_service.dart';
import '../../../data/models/commission_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import 'package:intl/intl.dart';

/// Pantalla de detalle de comisión
class CommissionDetailScreen extends ConsumerStatefulWidget {
  final int commissionId;

  const CommissionDetailScreen({
    super.key,
    required this.commissionId,
  });

  @override
  ConsumerState<CommissionDetailScreen> createState() => _CommissionDetailScreenState();
}

class _CommissionDetailScreenState extends ConsumerState<CommissionDetailScreen> {
  CommissionModel? _commission;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommission();
  }

  Future<void> _loadCommission() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final commission = await CommissionService.getCommission(widget.commissionId);
      setState(() {
        _commission = commission;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Comisión'),
        ),
        body: const LoadingIndicator(),
      );
    }

    if (_error != null || _commission == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Comisión'),
        ),
        body: app_error.AppErrorWidget(
          message: _error ?? 'Comisión no encontrada',
          onRetry: _loadCommission,
        ),
      );
    }

    final formatter = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Comisión'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información principal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comisión #${_commission!.id}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        _buildStatusChip(_commission!.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tipo', _commission!.commissionType),
                    const Divider(),
                    _buildInfoRow(
                      'Monto Total',
                      formatter.format(_commission!.totalCommission),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Información del proyecto y unidad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proyecto y Unidad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_commission!.project != null)
                      _buildInfoRow('Proyecto', _commission!.project!.name),
                    if (_commission!.unit != null)
                      _buildInfoRow('Unidad', _commission!.unit!.unitNumber),
                    if (_commission!.opportunity != null)
                      _buildInfoRow(
                        'Cliente',
                        _commission!.opportunity!.clientName,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detalles de la comisión
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de Comisión',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Monto Base',
                      formatter.format(_commission!.baseAmount),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Porcentaje',
                      '${_commission!.commissionPercentage}%',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Comisión',
                      formatter.format(_commission!.commissionAmount),
                    ),
                    if (_commission!.bonusAmount > 0) ...[
                      const Divider(),
                      _buildInfoRow(
                        'Bono',
                        formatter.format(_commission!.bonusAmount),
                      ),
                    ],
                    const Divider(),
                    _buildInfoRow(
                      'Total',
                      formatter.format(_commission!.totalCommission),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Información de pago
            if (_commission!.status == 'pagada' ||
                _commission!.paymentDate != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Pago',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (_commission!.paymentDate != null)
                        _buildInfoRow(
                          'Fecha de Pago',
                          dateFormatter.format(DateTime.parse(_commission!.paymentDate!)),
                        ),
                      if (_commission!.paymentMethod != null)
                        _buildInfoRow(
                          'Método',
                          _commission!.paymentMethod!,
                        ),
                      if (_commission!.paymentReference != null)
                        _buildInfoRow(
                          'Referencia',
                          _commission!.paymentReference!,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Fechas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fechas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Creada',
                      dateTimeFormatter.format(_commission!.createdAt),
                    ),
                    if (_commission!.approvedAt != null)
                      _buildInfoRow(
                        'Aprobada',
                        dateTimeFormatter.format(
                          DateTime.parse(_commission!.approvedAt!),
                        ),
                      ),
                    if (_commission!.paidAt != null)
                      _buildInfoRow(
                        'Pagada',
                        dateTimeFormatter.format(
                          DateTime.parse(_commission!.paidAt!),
                        ),
                      ),
                    _buildInfoRow(
                      'Actualizada',
                      dateTimeFormatter.format(_commission!.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
            if (_commission!.notes != null && _commission!.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_commission!.notes!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    color: isHighlight
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'aprobada':
        color = Colors.blue;
        label = 'Aprobada';
        break;
      case 'pagada':
        color = Colors.green;
        label = 'Pagada';
        break;
      case 'cancelada':
        color = Colors.red;
        label = 'Cancelada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

