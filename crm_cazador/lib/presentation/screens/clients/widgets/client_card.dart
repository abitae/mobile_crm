import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../data/models/client_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../widgets/common/animated_card.dart';

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
    final theme = Theme.of(context);
    final resolvedCreateMode = client.createMode ??
        (client.documentNumber.isNotEmpty ? 'dni' : 'phone');
    return RepaintBoundary(
      child: AnimatedCard(
        child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getCreateTypeColor(client.createType).withOpacity(
              client.createType != null ? 0.6 : 0.1,
            ),
            width: client.createType != null ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _showContextMenu(context);
            },
            borderRadius: BorderRadius.circular(16),
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
                        if (client.createType != null) ...[
                          const SizedBox(width: 6),
                          _CreateTypeChip(createType: client.createType),
                        ],
                        if (resolvedCreateMode.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _CreateModeChip(mode: resolvedCreateMode),
                        ],
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

  Color _getCreateTypeColor(String? createType) {
    if (createType == null) {
      return AppColors.outline;
    }
    switch (createType.toLowerCase()) {
      case 'datero':
        return AppColors.primary; // Azul
      case 'propio':
        return AppColors.success; // Verde
      default:
        return AppColors.outline;
    }
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${client.documentType}: ${client.documentNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Actions
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_note,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: const Text('Crear Actividad'),
                subtitle: const Text('Registrar una nueva actividad'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/clients/${client.id}/activities/new?clientName=${Uri.encodeComponent(client.name)}',
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                title: const Text('Crear Reserva'),
                subtitle: const Text('Registrar una nueva reserva'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/reservations/new?clientId=${client.id}');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                title: const Text('Editar Cliente'),
                subtitle: const Text('Modificar información del cliente'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/clients/${client.id}/edit');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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

class _CreateTypeChip extends StatelessWidget {
  final String? createType;

  const _CreateTypeChip({required this.createType});

  @override
  Widget build(BuildContext context) {
    if (createType == null) return const SizedBox.shrink();

    final color = _getCreateTypeColor(createType);
    final label = _getCreateTypeLabel(createType);

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: color.withOpacity(0.5), width: 1),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getCreateTypeColor(String? createType) {
    if (createType == null) {
      return AppColors.outline;
    }
    switch (createType.toLowerCase()) {
      case 'datero':
        return AppColors.primary; // Azul
      case 'propio':
        return AppColors.success; // Verde
      default:
        return AppColors.outline;
    }
  }

  String _getCreateTypeLabel(String? createType) {
    if (createType == null) return '';
    switch (createType.toLowerCase()) {
      case 'datero':
        return 'Datero';
      case 'propio':
        return 'Propio';
      default:
        return createType;
    }
  }
}

class _CreateModeChip extends StatelessWidget {
  final String mode;

  const _CreateModeChip({required this.mode});

  @override
  Widget build(BuildContext context) {
    final color = _getCreateModeColor(mode);
    final label = _getCreateModeLabel(mode);

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: color.withOpacity(0.5), width: 1),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getCreateModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'dni':
        return AppColors.primary;
      case 'phone':
        return AppColors.warning;
      default:
        return AppColors.outline;
    }
  }

  String _getCreateModeLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'dni':
        return 'DNI';
      case 'phone':
        return 'Phone';
      default:
        return mode;
    }
  }
}
