import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/reservation_service.dart';
import '../../../data/services/project_service.dart';
import '../../../data/models/reservation_model.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/unit_model.dart';
import '../../../core/exceptions/api_exception.dart';

/// Pantalla de formulario de reserva (crear/editar)
class ReservationFormScreen extends ConsumerStatefulWidget {
  final int? reservationId;

  const ReservationFormScreen({super.key, this.reservationId});

  @override
  ConsumerState<ReservationFormScreen> createState() =>
      _ReservationFormScreenState();
}

class _ReservationFormScreenState
    extends ConsumerState<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservationAmountController = TextEditingController();
  final _reservationPercentageController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _paymentReferenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _reservationDate;
  DateTime? _expirationDate;
  int? _selectedClientId;
  String? _selectedClientName;
  int? _selectedProjectId;
  String? _selectedProjectName;
  int? _selectedUnitId;
  List<UnitModel> _availableUnits = [];
  bool _isLoadingUnits = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _reservationDate = DateTime.now();
    if (widget.reservationId != null) {
      _loadReservation();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _reservationAmountController.dispose();
    _reservationPercentageController.dispose();
    _paymentMethodController.dispose();
    _paymentReferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadReservation() async {
    try {
      final reservation = await ReservationService.getReservation(
          widget.reservationId!);
      _selectedClientId = reservation.clientId;
      _selectedProjectId = reservation.projectId;
      _selectedUnitId = reservation.unitId;
      _reservationDate = reservation.reservationDate;
      _expirationDate = reservation.expirationDate;
      _reservationAmountController.text =
          reservation.reservationAmount.toStringAsFixed(2);
      if (reservation.reservationPercentage != null) {
        _reservationPercentageController.text =
            reservation.reservationPercentage!.toStringAsFixed(2);
      }
      _paymentMethodController.text = reservation.paymentMethod ?? '';
      _paymentReferenceController.text = reservation.paymentReference ?? '';
      _notesController.text = reservation.notes ?? '';

      // Cargar datos relacionados
      if (reservation.client != null) {
        _selectedClientName = reservation.client!.name;
      }
      if (reservation.project != null) {
        _selectedProjectName = reservation.project!.name;
        await _loadUnitsForProject(reservation.project!.id);
      }
      if (reservation.unit != null && _availableUnits.isNotEmpty) {
        final unit = _availableUnits.firstWhere(
          (u) => u.id == reservation.unit!.id,
          orElse: () => _availableUnits.first,
        );
        _selectedUnitId = unit.id;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar reserva: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _loadUnitsForProject(int projectId) async {
    setState(() {
      _isLoadingUnits = true;
      _availableUnits = [];
      _selectedUnitId = null;
    });

    try {
      final response = await ProjectService.getProjectUnits(
        projectId: projectId,
        page: 1,
        perPage: 100,
      );
      setState(() {
        _availableUnits = response.data.where((u) => u.status == 'disponible').toList();
        _isLoadingUnits = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUnits = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar unidades: $e')),
        );
      }
    }
  }

  Future<void> _selectClient() async {
    final client = await context.push<ClientModel>('/clients/select');
    if (client != null) {
      setState(() {
        _selectedClientId = client.id;
        _selectedClientName = client.name;
      });
    }
  }

  Future<void> _selectProject() async {
    final project = await context.push<ProjectModel>('/projects/select');
    if (project != null) {
      setState(() {
        _selectedProjectId = project.id;
        _selectedProjectName = project.name;
      });
      await _loadUnitsForProject(project.id);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authNotifierProvider).currentState;
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reservation = ReservationModel(
        id: widget.reservationId ?? 0,
        reservationNumber: '',
        clientId: _selectedClientId!,
        projectId: _selectedProjectId!,
        unitId: _selectedUnitId!,
        advisorId: authState.user!.id,
        reservationType: 'pre_reserva',
        status: 'activa',
        reservationDate: _reservationDate!,
        expirationDate: _expirationDate,
        reservationAmount: double.parse(_reservationAmountController.text),
        reservationPercentage: _reservationPercentageController.text.isNotEmpty
            ? double.tryParse(_reservationPercentageController.text)
            : null,
        paymentMethod: _paymentMethodController.text.isNotEmpty
            ? _paymentMethodController.text
            : null,
        paymentReference: _paymentReferenceController.text.isNotEmpty
            ? _paymentReferenceController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        paymentStatus: 'pendiente',
      );

      if (widget.reservationId != null) {
        await ReservationService.updateReservation(
            widget.reservationId!, reservation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ReservationService.createReservation(reservation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      ref.read(reservationsNotifierProvider).refreshReservations();
      if (mounted) {
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservationId == null
            ? 'Nueva Reserva'
            : 'Editar Reserva'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cliente
              _buildSectionHeader('Cliente', Icons.person_outlined),
              ListTile(
                title: Text(_selectedClientName ?? 'Seleccionar cliente'),
                subtitle: _selectedClientId != null
                    ? Text('ID: $_selectedClientId')
                    : const Text('Requerido'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectClient,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _selectedClientId == null
                        ? Colors.red
                        : Colors.transparent,
                  ),
                ),
              ),
              if (_selectedClientId == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Cliente es requerido',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Proyecto
              _buildSectionHeader('Proyecto', Icons.business_outlined),
              ListTile(
                title: Text(_selectedProjectName ?? 'Seleccionar proyecto'),
                subtitle: _selectedProjectId != null
                    ? Text('ID: $_selectedProjectId')
                    : const Text('Requerido'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectProject,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _selectedProjectId == null
                        ? Colors.red
                        : Colors.transparent,
                  ),
                ),
              ),
              if (_selectedProjectId == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Proyecto es requerido',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Unidad
              _buildSectionHeader('Unidad', Icons.home_outlined),
              if (_isLoadingUnits)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_selectedProjectId == null)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Selecciona un proyecto primero'),
                )
              else if (_availableUnits.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No hay unidades disponibles'),
                )
              else
                DropdownButtonFormField<int>(
                  value: _selectedUnitId,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableUnits.map((unit) {
                    return DropdownMenuItem<int>(
                      value: unit.id,
                      child: Text(_getUnitLabel(unit)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnitId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Unidad es requerida';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Fecha de Reserva
              _buildSectionHeader('Fechas', Icons.calendar_today_outlined),
              ListTile(
                title: const Text('Fecha de Reserva'),
                subtitle: Text(_reservationDate != null
                    ? dateFormat.format(_reservationDate!)
                    : 'Seleccionar fecha'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _reservationDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _reservationDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Fecha de Vencimiento (Opcional)'),
                subtitle: Text(_expirationDate != null
                    ? dateFormat.format(_expirationDate!)
                    : 'Seleccionar fecha'),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expirationDate ??
                        _reservationDate?.add(const Duration(days: 30)) ??
                        DateTime.now(),
                    firstDate: _reservationDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _expirationDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Montos
              _buildSectionHeader('Montos', Icons.attach_money),
              TextFormField(
                controller: _reservationAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto de Reserva *',
                  border: OutlineInputBorder(),
                  prefixText: 'S/ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Monto es requerido';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reservationPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje (Opcional)',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final percentage = double.tryParse(value);
                    if (percentage == null || percentage < 0 || percentage > 100) {
                      return 'Porcentaje debe estar entre 0 y 100';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Información de Pago
              _buildSectionHeader('Información de Pago', Icons.payment),
              TextFormField(
                controller: _paymentMethodController,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago (Opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Transferencia, Efectivo, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentReferenceController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de Pago (Opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Número de operación, código, etc.',
                ),
              ),
              const SizedBox(height: 16),

              // Notas
              _buildSectionHeader('Notas', Icons.note_outlined),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Botón de guardar
              FilledButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.reservationId == null
                        ? 'Crear Reserva'
                        : 'Actualizar Reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnitLabel(UnitModel unit) {
    if (unit.unitManzana != null) {
      return 'Mz. ${unit.unitManzana} • ${unit.unitNumber}';
    }
    return unit.unitNumber;
  }
}

