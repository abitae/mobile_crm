import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../../data/services/activity_service.dart';
import '../../../data/services/reservation_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeletons/client_detail_skeleton.dart';
import '../../../data/models/client_model.dart' as models;
import '../../../data/models/activity_model.dart';
import '../../../data/models/reservation_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Pantalla de detalle de cliente
class ClientDetailScreen extends ConsumerStatefulWidget {
  final int clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  List<ActivityModel>? _activities;
  List<ReservationModel>? _reservations;
  bool _isLoadingActivities = false;
  bool _isLoadingReservations = false;
  String? _activitiesError;
  String? _reservationsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('🔵 [ClientDetail] Iniciando carga de datos para cliente ID: ${widget.clientId}');
    _loadActivities();
    _loadReservations();
  }

  Future<void> _loadActivities() async {
    debugPrint('📋 [ClientDetail] Iniciando carga de actividades para cliente ID: ${widget.clientId}');
    setState(() {
      _isLoadingActivities = true;
      _activitiesError = null;
    });

    try {
      debugPrint('📋 [ClientDetail] Llamando a ActivityService.getClientActivitiesList(${widget.clientId}, perPage: 100)');
      final response = await ActivityService.getClientActivitiesList(
        widget.clientId,
        perPage: 100,
      );
      final activities = response.data;
      debugPrint('✅ [ClientDetail] Actividades recibidas: ${activities.length}');
      debugPrint('📊 [ClientDetail] Paginación - Total: ${response.totalItems}, Página: ${response.currentPage}');
      
      if (activities.isNotEmpty) {
        debugPrint('📋 [ClientDetail] Primera actividad:');
        debugPrint('   - ID: ${activities.first.id}');
        debugPrint('   - Título: ${activities.first.title}');
        debugPrint('   - Tipo: ${activities.first.activityType}');
        debugPrint('   - Descripción: ${activities.first.description}');
        debugPrint('   - Fecha/Hora: ${activities.first.startDate}');
        debugPrint('   - Notas: ${activities.first.notes}');
        debugPrint('   - Estado: ${activities.first.status}');
        debugPrint('   - Client ID: ${activities.first.clientId}');
      } else {
        debugPrint('⚠️ [ClientDetail] No se recibieron actividades (lista vacía)');
      }
      
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoadingActivities = false;
        });
        debugPrint('✅ [ClientDetail] Estado actualizado: ${activities.length} actividades');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [ClientDetail] Error al cargar actividades: $e');
      debugPrint('❌ [ClientDetail] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _activitiesError = e.toString();
          _isLoadingActivities = false;
        });
        debugPrint('❌ [ClientDetail] Error guardado en estado: $_activitiesError');
      }
    }
  }

  Future<void> _loadReservations() async {
    debugPrint('🎫 [ClientDetail] Iniciando carga de reservas para cliente ID: ${widget.clientId}');
    setState(() {
      _isLoadingReservations = true;
      _reservationsError = null;
    });

    try {
      debugPrint('🎫 [ClientDetail] Llamando a ReservationService.getReservations(clientId: ${widget.clientId}, perPage: 100)');
      final response = await ReservationService.getReservations(
        clientId: widget.clientId,
        perPage: 100,
      );
      debugPrint('✅ [ClientDetail] Reservas recibidas: ${response.data.length}');
      debugPrint('📊 [ClientDetail] Paginación - Total: ${response.totalItems}, Página actual: ${response.currentPage}');
      
      if (response.data.isNotEmpty) {
        debugPrint('🎫 [ClientDetail] Primera reserva:');
        debugPrint('   - ID: ${response.data.first.id}');
        debugPrint('   - Número: ${response.data.first.reservationNumber}');
        debugPrint('   - Estado: ${response.data.first.status}');
        debugPrint('   - Fecha: ${response.data.first.reservationDate}');
        debugPrint('   - Monto: ${response.data.first.reservationAmount}');
        debugPrint('   - Proyecto: ${response.data.first.project?.name ?? "N/A"}');
        debugPrint('   - Unidad: ${response.data.first.unit?.fullIdentifier ?? response.data.first.unit?.unitNumber ?? "N/A"}');
      } else {
        debugPrint('⚠️ [ClientDetail] No se recibieron reservas (lista vacía)');
      }
      
      if (mounted) {
        setState(() {
          _reservations = response.data;
          _isLoadingReservations = false;
        });
        debugPrint('✅ [ClientDetail] Estado actualizado: ${response.data.length} reservas');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [ClientDetail] Error al cargar reservas: $e');
      debugPrint('❌ [ClientDetail] StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _reservationsError = e.toString();
          _isLoadingReservations = false;
        });
        debugPrint('❌ [ClientDetail] Error guardado en estado: $_reservationsError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientProvider(widget.clientId));

    return Scaffold(
      appBar: AppBar(
        title: clientAsync.when(
          data: (client) => Text(client.name),
          loading: () => const Text('Detalle de Cliente'),
          error: (_, __) => const Text('Detalle de Cliente'),
        ),
        actions: [
          clientAsync.when(
            data: (client) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/clients/${widget.clientId}/edit');
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
        loading: () => const ClientDetailSkeleton(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(clientProvider(widget.clientId));
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
        ref.invalidate(clientProvider(widget.clientId));
        await _loadData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Acciones rápidas compactas
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/reservations/new?clientId=${widget.clientId}',
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Nueva Reserva'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/clients/${widget.clientId}/activities/new?clientName=${Uri.encodeComponent(client.name)}',
                      );
                    },
                    icon: const Icon(Icons.event_note, size: 18),
                    label: const Text('Nueva Actividad'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabla de Actividades
            _buildActivitiesTable(context, colorScheme),
            const SizedBox(height: 16),
            // Tabla de Reservas
            _buildReservationsTable(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTable(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final activitiesColor = Colors.blue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: activitiesColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: activitiesColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, color: activitiesColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Actividades',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: activitiesColor,
                  ),
                ),
                const Spacer(),
                if (_isLoadingActivities)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(activitiesColor),
                    ),
                  )
                else if (_activities != null)
                  Text(
                    '${_activities!.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: activitiesColor,
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoadingActivities)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_activitiesError != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_activitiesError',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            )
          else if (_activities == null || _activities!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay actividades',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            _buildActivitiesTableContent(context, theme, activitiesColor),
        ],
      ),
    );
  }

  Widget _buildActivitiesTableContent(
    BuildContext context,
    ThemeData theme,
    Color color,
  ) {
    debugPrint('📋 [ClientDetail] _buildActivitiesTableContent - Total actividades: ${_activities!.length}');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(color.withOpacity(0.1)),
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(label: Text('Fecha/Hora', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Título', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tipo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Notas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
        rows: _activities!.map<DataRow>((activity) {
          debugPrint('📋 [ClientDetail] Procesando actividad ID: ${activity.id}, Título: ${activity.title}, Tipo: ${activity.activityType}');
          return DataRow(
            cells: [
              DataCell(
                Text(
                  activity.startDate != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(activity.startDate!)
                      : activity.createdAt != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt!)
                          : '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    activity.title,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getActivityTypeLabel(activity.activityType),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(activity.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusLabel(activity.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(activity.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(
                    activity.notes ?? '-',
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReservationsTable(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final reservationsColor = Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: reservationsColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: reservationsColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: reservationsColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reservas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: reservationsColor,
                  ),
                ),
                const Spacer(),
                if (_isLoadingReservations)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(reservationsColor),
                    ),
                  )
                else if (_reservations != null)
                  Text(
                    '${_reservations!.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: reservationsColor,
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoadingReservations)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_reservationsError != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_reservationsError',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            )
          else if (_reservations == null || _reservations!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay reservas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Builder(
              builder: (context) {
                debugPrint('🎫 [ClientDetail] Construyendo tabla de reservas con ${_reservations!.length} items');
                return _buildReservationsTableContent(context, theme, reservationsColor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReservationsTableContent(
    BuildContext context,
    ThemeData theme,
    Color color,
  ) {
    debugPrint('🎫 [ClientDetail] _buildReservationsTableContent - Total reservas: ${_reservations!.length}');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(color.withOpacity(0.1)),
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(label: Text('Número', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Fecha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Proyecto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Unidad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Monto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
        rows: _reservations!.map<DataRow>((reservation) {
          debugPrint('🎫 [ClientDetail] Procesando reserva ID: ${reservation.id}, Número: ${reservation.reservationNumber}, Estado: ${reservation.status}');
          return DataRow(
            onSelectChanged: (_) {
              context.push('/reservations/${reservation.id}');
            },
            cells: [
              DataCell(
                Text(
                  reservation.reservationNumber,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  DateFormat('dd/MM/yyyy').format(reservation.reservationDate),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(
                    reservation.project?.name ?? '-',
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Text(
                  reservation.unit?.fullIdentifier ?? reservation.unit?.unitNumber ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReservationStatusColor(reservation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getReservationStatusLabel(reservation.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getReservationStatusColor(reservation.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  reservation.formattedReservationAmount ?? 
                  'S/ ${reservation.reservationAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getActivityTypeLabel(String type) {
    final labels = {
      'llamada': 'Llamada',
      'reunion': 'Reunión',
      'visita': 'Visita',
      'seguimiento': 'Seguimiento',
      'tarea': 'Tarea',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  String _getStatusLabel(String? status) {
    if (status == null) return 'N/A';
    final labels = {
      'programada': 'Programada',
      'en_progreso': 'En Progreso',
      'completada': 'Completada',
      'cancelada': 'Cancelada',
    };
    return labels[status.toLowerCase()] ?? status;
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'programada':
        return Colors.blue;
      case 'en_progreso':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getReservationStatusLabel(String status) {
    final labels = {
      'activa': 'Activa',
      'confirmada': 'Confirmada',
      'cancelada': 'Cancelada',
      'expirada': 'Expirada',
      'convertida': 'Convertida',
    };
    return labels[status.toLowerCase()] ?? status;
  }

  Color _getReservationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return Colors.blue;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'expirada':
        return Colors.orange;
      case 'convertida':
        return Colors.purple;
      default:
        return Colors.grey;
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
                  // Invalidar provider del cliente específico
                  ref.invalidate(clientProvider(client.id));
                  // Refrescar lista de clientes de forma reactiva
                  ref.read(clientsNotifierProvider).loadClients(refresh: true);
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
