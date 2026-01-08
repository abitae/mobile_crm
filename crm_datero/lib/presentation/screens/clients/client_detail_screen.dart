import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeleton_loader.dart';
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
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/clients/$clientId/edit');
                } else if (value == 'delete') {
                  _showDeleteDialog(context, ref, client);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
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
        data: (client) => _buildClientDetail(context, ref, client),
        loading: () => const LoadingIndicator(
          useSkeleton: true,
          skeletonType: SkeletonType.clientDetail,
        ),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(clientProvider(clientId));
          },
        ),
      ),
    );
  }

  Widget _buildClientDetail(
    BuildContext context,
    WidgetRef ref,
    models.ClientModel client,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(clientProvider(clientId));
      },
      child: CustomScrollView(
        slivers: [
          // Header con información principal
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          client.name.isNotEmpty
                              ? client.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${client.documentType}: ${client.documentNumber}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip(context, client.status),
                      _buildTypeChip(context, client.type),
                      _buildSourceChip(context, client.source),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Botón de editar prominente
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push('/clients/$clientId/edit');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Cliente'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Información de contacto
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildInfoSection(
                context,
                'Información de Contacto',
                Icons.contact_phone,
                [
                  if (client.phone != null)
                    _buildActionableInfoRow(
                      context,
                      Icons.phone,
                      'Teléfono',
                      client.phone!,
                      onTap: () => _launchPhone(client.phone!),
                    ),
                  if (client.email != null)
                    _buildActionableInfoRow(
                      context,
                      Icons.email,
                      'Email',
                      client.email!,
                      onTap: () => _launchEmail(client.email!),
                    ),
                  if (client.address != null)
                    _buildInfoRow(
                      context,
                      Icons.location_on,
                      'Dirección',
                      client.address!,
                    ),
                  if (client.birthDate != null)
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Fecha de Nacimiento',
                      _formatDate(client.birthDate!),
                    ),
                ],
              ),
            ),
          ),
          // Información del cliente
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildInfoSection(
                context,
                'Información del Cliente',
                Icons.info,
                [
                  _buildInfoRow(
                    context,
                    Icons.category,
                    'Tipo',
                    _getTypeLabel(client.type),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.flag,
                    'Estado',
                    _getStatusLabel(client.status),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.place,
                    'Origen',
                    _getSourceLabel(client.source),
                  ),
                  _buildScoreRow(context, client.score),
                ],
              ),
            ),
          ),
          // Notas
          if (client.notes != null && client.notes!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildInfoSection(
                  context,
                  'Notas',
                  Icons.note,
                  [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        client.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Métricas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMetricsSection(context, client),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color chipColor;
    IconData icon;

    switch (status) {
      case 'nuevo':
        chipColor = Colors.blue;
        icon = Icons.star;
        break;
      case 'contacto_inicial':
        chipColor = Colors.orange;
        icon = Icons.phone;
        break;
      case 'en_seguimiento':
        chipColor = Colors.purple;
        icon = Icons.track_changes;
        break;
      case 'cierre':
        chipColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'perdido':
        chipColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        chipColor = colorScheme.surfaceVariant;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: chipColor),
      label: Text(_getStatusLabel(status)),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTypeChip(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.category, size: 16, color: colorScheme.primary),
      label: Text(_getTypeLabel(type)),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSourceChip(BuildContext context, String source) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.place, size: 16, color: colorScheme.secondary),
      label: Text(_getSourceLabel(source)),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData titleIcon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(titleIcon, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context, int score) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, size: 24, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$score',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    models.ClientModel client,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Métricas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  context,
                  Icons.work_outline,
                  'Oportunidades',
                  client.opportunitiesCount ?? 0,
                  colorScheme.primary,
                ),
                _buildMetric(
                  context,
                  Icons.event_note,
                  'Actividades',
                  client.activitiesCount ?? 0,
                  colorScheme.secondary,
                ),
                _buildMetric(
                  context,
                  Icons.task_alt,
                  'Tareas',
                  client.tasksCount ?? 0,
                  colorScheme.tertiary,
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
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
                  ref.invalidate(clientsNotifierProvider);
                  if (context.mounted) {
                    context.pop();
                  }
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
