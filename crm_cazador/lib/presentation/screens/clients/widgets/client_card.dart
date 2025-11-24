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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre y estado en una línea
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: client.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // DNI y teléfono en una línea compacta
                    Row(
                      children: [
                        Icon(
                          AppIcons.dni,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.documentNumber,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        if (client.phone != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            AppIcons.phone,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              client.phone!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Score y contadores compactos
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getScoreColor(client.score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.score,
                          size: 12,
                          color: _getScoreColor(client.score),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${client.score}',
                          style: TextStyle(
                            color: _getScoreColor(client.score),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contadores en una línea
                  if ((client.opportunitiesCount ?? 0) > 0 ||
                      (client.activitiesCount ?? 0) > 0 ||
                      (client.tasksCount ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if ((client.opportunitiesCount ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Badge(
                              label: Text(
                                '${client.opportunitiesCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(
                                MdiIcons.briefcase,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if ((client.activitiesCount ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Badge(
                              label: Text(
                                '${client.activitiesCount}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              child: Icon(
                                MdiIcons.calendarCheck,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if ((client.tasksCount ?? 0) > 0)
                          Badge(
                            label: Text(
                              '${client.tasksCount}',
                              style: const TextStyle(fontSize: 9),
                            ),
                            child: Icon(
                              MdiIcons.checkCircle,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      avatar: Icon(
        _getStatusIcon(status),
        size: 12,
        color: color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: color.withOpacity(0.3), width: 0.5),
      visualDensity: VisualDensity.compact,
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

