import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/reservations/reservation_card.dart';

/// Pantalla de listado de reservas
class ReservationsListScreen extends ConsumerStatefulWidget {
  const ReservationsListScreen({super.key});

  @override
  ConsumerState<ReservationsListScreen> createState() =>
      _ReservationsListScreenState();
}

class _ReservationsListScreenState
    extends ConsumerState<ReservationsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && maxScroll > 0) {
      ref.read(reservationsNotifierProvider).loadMoreReservations();
    }
  }

  void _handleSearch(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        ref.read(reservationsNotifierProvider).setSearch(
              query.isEmpty ? null : query,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationsState =
        ref.watch(reservationsNotifierProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar reservas',
                hintText: 'Número, cliente, proyecto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(reservationsNotifierProvider).setSearch(null);
                        },
                      )
                    : null,
                filled: true,
              ),
              onChanged: _handleSearch,
            ),
          ),
          // Active filters chips
          if (reservationsState.statusFilter != null ||
              reservationsState.paymentStatusFilter != null ||
              reservationsState.projectIdFilter != null ||
              reservationsState.clientIdFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (reservationsState.statusFilter != null)
                    FilterChip(
                      label: Text(_getStatusLabel(reservationsState.statusFilter!)),
                      onSelected: (_) {
                        ref.read(reservationsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(reservationsNotifierProvider).setFilters(
                              status: null,
                            );
                      },
                    ),
                  if (reservationsState.paymentStatusFilter != null)
                    FilterChip(
                      label: Text(_getPaymentStatusLabel(
                          reservationsState.paymentStatusFilter!)),
                      onSelected: (_) {
                        ref.read(reservationsNotifierProvider).setFilters(
                              paymentStatus: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(reservationsNotifierProvider).setFilters(
                              paymentStatus: null,
                            );
                      },
                    ),
                  if (reservationsState.projectIdFilter != null)
                    FilterChip(
                      label: Text('Proyecto ${reservationsState.projectIdFilter}'),
                      onSelected: (_) {
                        ref.read(reservationsNotifierProvider).setFilters(
                              projectId: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(reservationsNotifierProvider).setFilters(
                              projectId: null,
                            );
                      },
                    ),
                  if (reservationsState.clientIdFilter != null)
                    FilterChip(
                      label: Text('Cliente ${reservationsState.clientIdFilter}'),
                      onSelected: (_) {
                        ref.read(reservationsNotifierProvider).setFilters(
                              clientId: null,
                            );
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(reservationsNotifierProvider).setFilters(
                              clientId: null,
                            );
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(reservationsNotifierProvider).refreshReservations();
              },
              child: _buildBody(reservationsState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/reservations/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final reservationsState =
        ref.read(reservationsNotifierProvider).currentState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        reservationsState: reservationsState,
        onApply: (status, paymentStatus, projectId, clientId) {
          ref.read(reservationsNotifierProvider).setFilters(
                status: status,
                paymentStatus: paymentStatus,
                projectId: projectId,
                clientId: clientId,
              );
        },
        onClear: () {
          ref.read(reservationsNotifierProvider).clearFilters();
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    final labels = {
      'activa': 'Activa',
      'confirmada': 'Confirmada',
      'cancelada': 'Cancelada',
      'vencida': 'Vencida',
      'convertida_venta': 'Convertida',
    };
    return labels[status] ?? status;
  }

  String _getPaymentStatusLabel(String paymentStatus) {
    final labels = {
      'pagado': 'Pagado',
      'pendiente': 'Pendiente',
      'parcial': 'Parcial',
    };
    return labels[paymentStatus] ?? paymentStatus;
  }

  Widget _buildBody(ReservationsState state) {
    if (state.isLoading && state.reservations.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.reservations.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(reservationsNotifierProvider).loadReservations(refresh: true);
        },
      );
    }

    if (state.reservations.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No hay reservas',
        message: 'Comienza creando tu primera reserva',
        action: () {
          context.push('/reservations/new');
        },
        actionLabel: 'Crear Reserva',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.reservations.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.reservations.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reservation = state.reservations[index];
        return ReservationCard(
          reservation: reservation,
          onTap: () {
            context.push('/reservations/${reservation.id}');
          },
        );
      },
    );
  }
}

/// Widget para el bottom sheet de filtros
class _FilterBottomSheet extends ConsumerStatefulWidget {
  final ReservationsState reservationsState;
  final void Function(String? status, String? paymentStatus, int? projectId,
      int? clientId) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.reservationsState,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late String? _selectedStatus;
  late String? _selectedPaymentStatus;
  String? _projectIdText;
  String? _clientIdText;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.reservationsState.statusFilter;
    _selectedPaymentStatus = widget.reservationsState.paymentStatusFilter;
    _projectIdText = widget.reservationsState.projectIdFilter?.toString();
    _clientIdText = widget.reservationsState.clientIdFilter?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filtro de Estado
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos los estados'),
              ),
              const DropdownMenuItem<String>(
                value: 'activa',
                child: Text('Activa'),
              ),
              const DropdownMenuItem<String>(
                value: 'confirmada',
                child: Text('Confirmada'),
              ),
              const DropdownMenuItem<String>(
                value: 'cancelada',
                child: Text('Cancelada'),
              ),
              const DropdownMenuItem<String>(
                value: 'vencida',
                child: Text('Vencida'),
              ),
              const DropdownMenuItem<String>(
                value: 'convertida_venta',
                child: Text('Convertida a Venta'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Filtro de Estado de Pago
          DropdownButtonFormField<String>(
            value: _selectedPaymentStatus,
            decoration: const InputDecoration(
              labelText: 'Estado de Pago',
              prefixIcon: Icon(Icons.payment_outlined),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos los estados'),
              ),
              const DropdownMenuItem<String>(
                value: 'pagado',
                child: Text('Pagado'),
              ),
              const DropdownMenuItem<String>(
                value: 'pendiente',
                child: Text('Pendiente'),
              ),
              const DropdownMenuItem<String>(
                value: 'parcial',
                child: Text('Parcial'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Filtro de Proyecto ID
          TextField(
            decoration: const InputDecoration(
              labelText: 'ID de Proyecto',
              prefixIcon: Icon(Icons.business_outlined),
              hintText: 'Opcional',
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: _projectIdText),
            onChanged: (value) {
              _projectIdText = value.isEmpty ? null : value;
            },
          ),
          const SizedBox(height: 16),
          // Filtro de Cliente ID
          TextField(
            decoration: const InputDecoration(
              labelText: 'ID de Cliente',
              prefixIcon: Icon(Icons.person_outlined),
              hintText: 'Opcional',
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: _clientIdText),
            onChanged: (value) {
              _clientIdText = value.isEmpty ? null : value;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(
                      _selectedStatus,
                      _selectedPaymentStatus,
                      _projectIdText != null
                          ? int.tryParse(_projectIdText!)
                          : null,
                      _clientIdText != null
                          ? int.tryParse(_clientIdText!)
                          : null,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

