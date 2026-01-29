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
/// 
/// Permite crear una nueva actividad para un cliente.
/// 
/// Campos del formulario:
/// - Tipo de actividad (requerido): llamada, reunion, email, visita, seguimiento, cotizacion, otro
/// - Descripción (requerido): Descripción de la actividad realizada
/// - Fecha (opcional): Fecha de la actividad (por defecto: fecha actual)
/// - Notas (opcional): Notas adicionales sobre la actividad
/// 
/// Al guardar, se envía al endpoint POST /clients/{client}/activities con:
/// - type: Tipo seleccionado
/// - description: Descripción ingresada
/// - activity_date: Fecha seleccionada (si existe)
/// - notes: Notas ingresadas (si no está vacío)
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
  final _titleController = TextEditingController(); // Título (requerido)
  final _descriptionController = TextEditingController(); // Descripción (opcional)
  final _notesController = TextEditingController();

  String? _selectedType;
  DateTime? _startDate; // start_date con hora
  TimeOfDay? _startTime; // Hora de inicio
  bool _isLoading = false;

  // Tipos válidos según documentación: llamada|reunion|visita|seguimiento|tarea
  final List<String> _activityTypes = [
    'llamada',
    'reunion',
    'visita',
    'seguimiento',
    'tarea',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _startTime = TimeOfDay.fromDateTime(now);
    _selectedType = _activityTypes.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Si no hay hora seleccionada, usar la hora actual
        if (_startTime == null) {
          _startTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación adicional de campos requeridos según documentación
    if (_selectedType == null || _selectedType!.isEmpty) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Por favor selecciona un tipo de actividad',
          type: SnackbarType.error,
        );
      }
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'El título es requerido',
          type: SnackbarType.error,
        );
      }
      return;
    }

    if (_startDate == null) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'La fecha de inicio es requerida',
          type: SnackbarType.error,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Construir start_date con fecha y hora
      DateTime? startDateTime;
      if (_startDate != null) {
        final time = _startTime ?? TimeOfDay.now();
        startDateTime = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          time.hour,
          time.minute,
        );
      }

      // Crear el modelo de actividad con los campos validados según documentación
      final activity = ActivityModel(
        clientId: widget.clientId,
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        activityType: _selectedType!,
        startDate: startDateTime,
        status: 'programada', // Default según documentación
        priority: 'media', // Default según documentación
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Validar que el JSON de creación sea correcto
      final createJson = activity.toCreateJson();
      if (createJson['title'] == null || createJson['title'].toString().isEmpty) {
        throw Exception('El título es requerido');
      }
      if (createJson['activity_type'] == null || createJson['activity_type'].toString().isEmpty) {
        throw Exception('El tipo de actividad es requerido');
      }
      if (createJson['start_date'] == null || createJson['start_date'].toString().isEmpty) {
        throw Exception('La fecha de inicio es requerida');
      }

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
    } catch (e, stackTrace) {
      if (mounted) {
        // Manejar errores inesperados con más detalle
        String errorMessage = 'Error al crear actividad';
        
        if (e.toString().contains('Null') && e.toString().contains('int')) {
          errorMessage = 'Error: El servidor devolvió datos inválidos. Por favor intenta nuevamente.';
        } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          errorMessage = 'Tiempo de espera agotado. Verifica tu conexión e intenta nuevamente.';
        } else {
          errorMessage = 'Error inesperado: ${e.toString()}';
        }
        
        CustomSnackbar.show(
          context,
          errorMessage,
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

              // Título (requerido)
              _buildSectionHeader('Título', Icons.title),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Llamada inicial, Reunión de seguimiento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de actividad (requerido)
              _buildSectionHeader('Tipo de Actividad', Icons.category),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
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

              // Fecha y hora de inicio (requerido)
              _buildSectionHeader('Fecha y Hora de Inicio', Icons.calendar_today),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _startDate != null
                            ? dateFormat.format(_startDate!)
                            : 'Seleccionar fecha',
                      ),
                      subtitle: const Text('Fecha'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _startTime != null
                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                            : 'Seleccionar hora',
                      ),
                      subtitle: const Text('Hora'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción (opcional)
              _buildSectionHeader('Descripción', Icons.description),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción detallada de la actividad (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
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
      'visita': 'Visita',
      'seguimiento': 'Seguimiento',
      'tarea': 'Tarea',
    };
    return labels[type] ?? type;
  }
}
