import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/project_model.dart';
import '../common/animated_card.dart';

/// Widget para mostrar una tarjeta de proyecto
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedCard(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre y tipo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildChip(
                              context,
                              _getProjectTypeLabel(project.projectType),
                              colorScheme.primary,
                            ),
                            if (project.loteType != null) ...[
                              const SizedBox(width: 8),
                              _buildChip(
                                context,
                                _getLoteTypeLabel(project.loteType!),
                                colorScheme.secondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                      ),
                    _buildStatusChip(context, project.status),
                  ],
                ),
                  const SizedBox(height: 12),
                  
                  // Descripción
                  if (project.description != null && project.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                    project.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Ubicación
                  if (project.fullAddress != null || project.district != null)
                    Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openLocation(context, project),
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            project.fullAddress ?? 
                            '${project.district ?? ''}, ${project.province ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openLocation(context, project),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.map_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                  // Estadísticas de unidades
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                    _buildStatItem(
                      context,
                      'Total',
                      project.totalUnits.toString(),
                      Icons.home_outlined,
                    ),
                    _buildStatItem(
                      context,
                      'Disponibles',
                      project.availableUnits.toString(),
                      Icons.check_circle_outline,
                      colorScheme.primary,
                    ),
                    _buildStatItem(
                      context,
                      'Vendidos',
                      project.soldUnits.toString(),
                      Icons.sell_outlined,
                      colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 12),

                  // Progreso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso de ventas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${project.progressPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: project.progressPercentage / 100,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      minHeight: 6,
                    ),
                  ],
                ),

                  // Etapa y estado legal
                  if (project.stage != null || project.legalStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (project.stage != null)
                            _buildInfoChip(
                              context,
                              'Etapa: ${_getStageLabel(project.stage!)}',
                            ),
                          if (project.legalStatus != null)
                            _buildInfoChip(
                              context,
                              'Legal: ${_getLegalStatusLabel(project.legalStatus!)}',
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = color ?? colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
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

  Future<void> _openLocation(BuildContext context, ProjectModel project) async {
    try {
      Uri? uri;

      // Si hay una URL de ubicación directa, usarla
      if (project.ubicacion != null && project.ubicacion!.isNotEmpty) {
        final ubicacionUrl = project.ubicacion!;
        // Si ya es una URL completa, usarla directamente
        if (ubicacionUrl.startsWith('http://') || ubicacionUrl.startsWith('https://')) {
          uri = Uri.parse(ubicacionUrl);
        } else if (ubicacionUrl.startsWith('geo:')) {
          // Formato geo:lat,lng
          uri = Uri.parse(ubicacionUrl);
        } else {
          // Si es solo coordenadas o dirección, construir URL de Google Maps
          uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(ubicacionUrl)}');
        }
      }
      // Si hay coordenadas, usar coordenadas
      else if (project.coordinates != null && 
               project.coordinates!['lat'] != null && 
               project.coordinates!['lng'] != null) {
        final lat = project.coordinates!['lat']!;
        final lng = project.coordinates!['lng']!;
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      }
      // Si hay dirección completa, buscar por dirección
      else if (project.fullAddress != null && project.fullAddress!.isNotEmpty) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(project.fullAddress!)}');
      }
      // Si hay distrito, provincia, región, construir dirección
      else if (project.district != null || project.province != null || project.region != null) {
        final address = '${project.district ?? ''}, ${project.province ?? ''}, ${project.region ?? ''}'.trim();
        if (address.isNotEmpty) {
          uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
        }
      }

      if (uri != null) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir Google Maps'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay información de ubicación disponible'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir la ubicación: $e'),
          ),
        );
      }
    }
  }
}

