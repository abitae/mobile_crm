import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../data/models/client_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';

/// Card de cliente siguiendo Material Design 3
class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _StatusChip(status: client.status),
                ],
              ),
              const SizedBox(height: 8),

              // Información del cliente
              Row(
                children: [
                  Icon(
                    AppIcons.dni,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${client.documentType}: ${client.documentNumber}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (client.phone != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      AppIcons.phone,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      client.phone!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer con acciones y métricas
              Row(
                children: [
                  // Score
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(client.score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.score,
                          size: 14,
                          color: _getScoreColor(client.score),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${client.score}',
                          style: TextStyle(
                            color: _getScoreColor(client.score),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Contadores con Badge Material 3
                  if ((client.opportunitiesCount ?? 0) > 0)
                    Badge(
                      label: Text('${client.opportunitiesCount}'),
                      child: Icon(
                        MdiIcons.briefcase,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  if ((client.activitiesCount ?? 0) > 0) ...[
                    const SizedBox(width: 8),
                    Badge(
                      label: Text('${client.activitiesCount}'),
                      child: Icon(
                        MdiIcons.calendarCheck,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if ((client.tasksCount ?? 0) > 0) ...[
                    const SizedBox(width: 8),
                    Badge(
                      label: Text('${client.tasksCount}'),
                      child: Icon(
                        MdiIcons.checkCircle,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Chip(
      label: Text(
        _getStatusLabel(status),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      avatar: Icon(
        _getStatusIcon(status),
        size: 16,
        color: color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: color.withOpacity(0.3)),
    );
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

  Color _getStatusColor(String status) {
    final colors = {
      'nuevo': AppColors.info,
      'contacto_inicial': AppColors.primary,
      'en_seguimiento': AppColors.warning,
      'cierre': AppColors.success,
      'perdido': AppColors.error,
    };
    return colors[status] ?? AppColors.onSurfaceVariant;
  }

  IconData _getStatusIcon(String status) {
    final icons = {
      'nuevo': AppIcons.newStatus,
      'contacto_inicial': AppIcons.contactInitial,
      'en_seguimiento': AppIcons.followUp,
      'cierre': AppIcons.closing,
      'perdido': AppIcons.lost,
    };
    return icons[status] ?? MdiIcons.circle;
  }
}

