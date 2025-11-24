import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/project_model.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import 'package:intl/intl.dart';

/// Pantalla de detalle de proyecto
class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Proyecto'),
      ),
      body: projectAsync.when(
        data: (project) => _buildProjectDetail(context, project),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(projectProvider(projectId));
          },
        ),
      ),
    );
  }

  Widget _buildProjectDetail(BuildContext context, ProjectModel project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de portada (si existe)
          if (project.pathImagePortada != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                image: project.pathImagePortada != null
                    ? DecorationImage(
                        image: NetworkImage(project.pathImagePortada!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: project.pathImagePortada == null
                  ? Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y tipo
                Text(
                  project.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip(context, _getProjectTypeLabel(project.projectType), colorScheme.primary),
                    if (project.loteType != null)
                      _buildChip(context, _getLoteTypeLabel(project.loteType!), colorScheme.secondary),
                    _buildStatusChip(context, project.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Descripción
                if (project.description != null && project.description!.isNotEmpty) ...[
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],

                // Ubicación
                if (project.fullAddress != null || project.district != null) ...[
                  Text(
                    'Ubicación',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project.fullAddress ?? 
                          '${project.district ?? ''}, ${project.province ?? ''}, ${project.region ?? ''}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (project.ubicacion != null)
                        IconButton(
                          icon: const Icon(Icons.map_outlined),
                          onPressed: () {
                            // TODO: Implementar url_launcher cuando se agregue la dependencia
                            // final uri = Uri.parse(project.ubicacion!);
                            // if (await canLaunchUrl(uri)) {
                            //   await launchUrl(uri, mode: LaunchMode.externalApplication);
                            // }
                          },
                          tooltip: 'Ver en mapa',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Estadísticas de unidades
                Text(
                  'Unidades',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(context, 'Total', project.totalUnits.toString(), Icons.home_outlined),
                          _buildStatCard(context, 'Disponibles', project.availableUnits.toString(), Icons.check_circle_outline, colorScheme.primary),
                          _buildStatCard(context, 'Reservados', project.reservedUnits.toString(), Icons.schedule, Colors.orange),
                          _buildStatCard(context, 'Vendidos', project.soldUnits.toString(), Icons.sell_outlined, colorScheme.secondary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progreso
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso de ventas',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${project.progressPercentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: project.progressPercentage / 100,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Información adicional
                if (project.stage != null || project.legalStatus != null || project.tipoFinanciamiento != null) ...[
                  Text(
                    'Información Adicional',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildInfoRows(context, project),
                  const SizedBox(height: 16),
                ],

                // Fechas importantes
                if (project.startDate != null || project.endDate != null || project.deliveryDate != null) ...[
                  Text(
                    'Fechas Importantes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildDateRows(context, project),
                  const SizedBox(height: 16),
                ],

                // Botón para ver unidades
                FilledButton.icon(
                  onPressed: () {
                    context.push('/projects/${project.id}/units');
                  },
                  icon: const Icon(Icons.list),
                  label: Text('Ver ${project.availableUnits} unidades disponibles'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, [Color? color]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = color ?? colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInfoRows(BuildContext context, ProjectModel project) {
    final rows = <Widget>[];

    if (project.stage != null) {
      rows.add(_buildInfoRow(context, 'Etapa', _getStageLabel(project.stage!)));
    }
    if (project.legalStatus != null) {
      rows.add(_buildInfoRow(context, 'Estado Legal', _getLegalStatusLabel(project.legalStatus!)));
    }
    if (project.tipoFinanciamiento != null) {
      rows.add(_buildInfoRow(context, 'Financiamiento', _getFinanciamientoLabel(project.tipoFinanciamiento!)));
    }
    if (project.banco != null) {
      rows.add(_buildInfoRow(context, 'Banco', project.banco!));
    }

    return rows;
  }

  List<Widget> _buildDateRows(BuildContext context, ProjectModel project) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final rows = <Widget>[];

    if (project.startDate != null) {
      rows.add(_buildInfoRow(context, 'Fecha de inicio', dateFormat.format(project.startDate!)));
    }
    if (project.endDate != null) {
      rows.add(_buildInfoRow(context, 'Fecha de fin', dateFormat.format(project.endDate!)));
    }
    if (project.deliveryDate != null) {
      rows.add(_buildInfoRow(context, 'Fecha de entrega', dateFormat.format(project.deliveryDate!)));
    }

    return rows;
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _getStatusColorAndLabel(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'activo':
        return (Colors.green, 'Activo');
      case 'inactivo':
        return (Colors.grey, 'Inactivo');
      case 'suspendido':
        return (Colors.orange, 'Suspendido');
      case 'finalizado':
        return (Colors.blue, 'Finalizado');
      default:
        return (colorScheme.onSurfaceVariant, status);
    }
  }

  String _getProjectTypeLabel(String type) {
    final labels = {
      'lotes': 'Lotes',
      'casas': 'Casas',
      'departamentos': 'Departamentos',
      'oficinas': 'Oficinas',
      'mixto': 'Mixto',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  String _getLoteTypeLabel(String type) {
    final labels = {
      'normal': 'Normal',
      'express': 'Express',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  String _getStageLabel(String stage) {
    final labels = {
      'preventa': 'Preventa',
      'lanzamiento': 'Lanzamiento',
      'venta_activa': 'Venta Activa',
      'cierre': 'Cierre',
    };
    return labels[stage.toLowerCase()] ?? stage;
  }

  String _getLegalStatusLabel(String status) {
    final labels = {
      'con_titulo': 'Con Título',
      'en_tramite': 'En Trámite',
      'habilitado': 'Habilitado',
    };
    return labels[status.toLowerCase()] ?? status;
  }

  String _getFinanciamientoLabel(String tipo) {
    final labels = {
      'contado': 'Contado',
      'financiado': 'Financiado',
    };
    return labels[tipo.toLowerCase()] ?? tipo;
  }
}

