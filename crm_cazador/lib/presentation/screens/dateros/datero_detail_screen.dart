import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/datero_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeletons/datero_detail_skeleton.dart';
import '../../../data/models/datero_model.dart';

/// Pantalla de detalle de datero
class DateroDetailScreen extends ConsumerWidget {
  final int dateroId;

  const DateroDetailScreen({
    super.key,
    required this.dateroId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateroAsync = ref.watch(dateroProvider(dateroId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Datero'),
        actions: [
          dateroAsync.when(
            data: (datero) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/dateros/$dateroId/edit');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
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
      body: dateroAsync.when(
        data: (datero) => _buildDetail(context, ref, datero),
        loading: () => DateroDetailSkeleton(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(dateroProvider(dateroId));
          },
        ),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    DateroModel datero,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dateroProvider(dateroId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      datero.name.isNotEmpty
                          ? datero.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
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
                          datero.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              datero.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  datero.isActive ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              datero.isActive ? 'Activo' : 'Inactivo',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: datero.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Información básica',
            [
              _buildRow(context, Icons.badge, 'DNI', datero.dni),
              _buildRow(context, Icons.phone, 'Teléfono', datero.phone),
              _buildRow(context, Icons.email, 'Email', datero.email),
              if (datero.ocupacion != null && datero.ocupacion!.isNotEmpty)
                _buildRow(context, Icons.work_outline, 'Ocupación', datero.ocupacion!),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Información bancaria',
            [
              _buildRow(
                context,
                Icons.account_balance,
                'Banco',
                datero.banco ?? '-',
              ),
              _buildRow(
                context,
                Icons.credit_card,
                'Cuenta bancaria',
                datero.cuentaBancaria ?? '-',
              ),
              _buildRow(
                context,
                Icons.numbers,
                'CCI',
                datero.cciBancaria ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (datero.lider != null)
            _buildSection(
              context,
              'Líder',
              [
                _buildRow(
                  context,
                  Icons.person,
                  'Nombre',
                  (datero.lider?['name'] as String?) ?? '-',
                ),
                _buildRow(
                  context,
                  Icons.email,
                  'Email',
                  (datero.lider?['email'] as String?) ?? '-',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
}


