import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../theme/app_icons.dart';
import '../../../data/models/client_model.dart' as models;
import '../../../core/exceptions/api_exception.dart';

/// Pantalla de detalle de cliente
class ClientDetailScreen extends ConsumerWidget {
  final int clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cliente'),
        actions: [
          clientAsync.when(
            data: (client) => PopupMenuButton<String>(
              icon: Icon(AppIcons.more),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/clients/$clientId/edit');
                } else if (value == 'delete') {
                  _showDeleteDialog(context, ref, client);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.editClient, size: 20),
                      const SizedBox(width: 8),
                      const Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(AppIcons.deleteClient, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: clientAsync.when(
        data: (client) => _buildClientDetail(context, client),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(clientProvider(clientId));
          },
        ),
      ),
    );
  }

  Widget _buildClientDetail(BuildContext context, models.ClientModel client) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${client.documentType}: ${client.documentNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            'Información de Contacto',
            [
              if (client.phone != null)
                _buildInfoRow(
                  context,
                  AppIcons.phone,
                  'Teléfono',
                  client.phone!,
                ),
              if (client.email != null)
                _buildInfoRow(
                  context,
                  AppIcons.email,
                  'Email',
                  client.email!,
                ),
              if (client.address != null)
                _buildInfoRow(
                  context,
                  AppIcons.location,
                  'Dirección',
                  client.address!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            'Información del Cliente',
            [
              _buildInfoRow(
                context,
                AppIcons.type,
                'Tipo',
                _getTypeLabel(client.type),
              ),
              _buildInfoRow(
                context,
                AppIcons.status,
                'Estado',
                _getStatusLabel(client.status),
              ),
              _buildInfoRow(
                context,
                AppIcons.origin,
                'Origen',
                _getSourceLabel(client.source),
              ),
              _buildInfoRow(
                context,
                AppIcons.score,
                'Score',
                '${client.score}',
              ),
              if (client.birthDate != null)
                _buildInfoRow(
                  context,
                  AppIcons.calendar,
                  'Fecha de Nacimiento',
                  _formatDate(client.birthDate!),
                ),
            ],
          ),
          if (client.notes != null && client.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Notas',
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    client.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _buildMetricsSection(context, client),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, client) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  context,
                  AppIcons.opportunities,
                  'Oportunidades',
                  client.opportunitiesCount ?? 0,
                ),
                _buildMetric(
                  context,
                  AppIcons.activities,
                  'Actividades',
                  client.activitiesCount ?? 0,
                ),
                _buildMetric(
                  context,
                  AppIcons.tasks,
                  'Tareas',
                  client.tasksCount ?? 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    IconData icon,
    String label,
    int value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getTypeLabel(String type) {
    final labels = {
      'inversor': 'Inversor',
      'comprador': 'Comprador',
      'empresa': 'Empresa',
      'constructor': 'Constructor',
    };
    return labels[type] ?? type;
  }

  String _getStatusLabel(String status) {
    final labels = {
      'nuevo': 'Nuevo',
      'contacto_inicial': 'Contacto Inicial',
      'en_seguimiento': 'En Seguimiento',
      'cierre': 'Cierre',
      'perdido': 'Perdido',
    };
    return labels[status] ?? status;
  }

  String _getSourceLabel(String source) {
    final labels = {
      'redes_sociales': 'Redes Sociales',
      'ferias': 'Ferias',
      'referidos': 'Referidos',
      'formulario_web': 'Formulario Web',
      'publicidad': 'Publicidad',
    };
    return labels[source] ?? source;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    models.ClientModel client,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ClientService.deleteClient(client.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado')),
                  );
                  ref.invalidate(clientsProvider);
                  context.pop();
                }
              } on ApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

