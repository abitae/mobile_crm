import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/services/activity_service.dart';
import '../../../data/models/activity_model.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../providers/client_provider.dart';

/// Pantalla de formulario de actividad
class ActivityFormScreen extends ConsumerStatefulWidget {
  final int clientId;
  final String? clientName;

  const ActivityFormScreen({
    super.key,
    required this.clientId,
    this.clientName,
  });

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedType;
  DateTime? _activityDate;
  bool _isLoading = false;

  final List<String> _activityTypes = [
    'llamada',
    'reunion',
    'email',
    'visita',
    'seguimiento',
    'cotizacion',
    'otro',
  ];

  @override
  void initState() {
    super.initState();
    _activityDate = DateTime.now();
    _selectedType = _activityTypes.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _activityDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final activity = ActivityModel(
        clientId: widget.clientId,
        type: _selectedType!,
        description: _descriptionController.text.trim(),
        activityDate: _activityDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ActivityService.createActivity(widget.clientId, activity);

      // Refrescar datos del cliente de forma reactiva
      ref.invalidate(clientProvider(widget.clientId));
      
      // Refrescar la lista de clientes para actualizar contadores del dashboard
      ref.read(clientsNotifierProvider).loadClients(refresh: true);

      if (mounted) {
        CustomSnackbar.show(
          context,
          'Actividad creada exitosamente',
          type: SnackbarType.success,
        );
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          e.message,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error al crear actividad: $e',
          type: SnackbarType.error,
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Actividad'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSubmit,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información del cliente
              if (widget.clientName != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                widget.clientName!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Tipo de actividad
              _buildSectionHeader('Tipo de Actividad', Icons.category),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: _activityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un tipo de actividad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              _buildSectionHeader('Descripción', Icons.description),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe la actividad realizada',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha
              _buildSectionHeader('Fecha', Icons.calendar_today),
              ListTile(
                title: Text(
                  _activityDate != null
                      ? dateFormat.format(_activityDate!)
                      : 'Seleccionar fecha',
                ),
                subtitle: const Text('Fecha de la actividad'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
              const SizedBox(height: 16),

              // Notas
              _buildSectionHeader('Notas', Icons.note),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  hintText: 'Notas opcionales sobre la actividad',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar Actividad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    final labels = {
      'llamada': 'Llamada',
      'reunion': 'Reunión',
      'email': 'Email',
      'visita': 'Visita',
      'seguimiento': 'Seguimiento',
      'cotizacion': 'Cotización',
      'otro': 'Otro',
    };
    return labels[type] ?? type;
  }
}
