import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/client_options.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../../core/exceptions/api_exception.dart';
import 'package:intl/intl.dart';

/// Pantalla de formulario de cliente (crear/editar)
class ClientFormScreen extends ConsumerStatefulWidget {
  final int? clientId;

  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedSource;
  int _score = 50;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClient();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    try {
      final client = await ClientService.getClient(widget.clientId!);
      _nameController.text = client.name;
      _documentNumberController.text = client.documentNumber;
      _phoneController.text = client.phone ?? '';
      _emailController.text = client.email ?? '';
      _addressController.text = client.address ?? '';
      _notesController.text = client.notes ?? '';
      _selectedDocumentType = client.documentType;
      _selectedType = client.type;
      _selectedStatus = client.status;
      _selectedSource = client.source;
      _score = client.score;
      _birthDate = client.birthDate;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cliente: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = ClientModel(
        id: widget.clientId ?? 0,
        name: _nameController.text.trim(),
        documentType: _selectedDocumentType ?? 'DNI',
        documentNumber: _documentNumberController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        birthDate: _birthDate,
        type: _selectedType ?? 'comprador',
        status: _selectedStatus ?? 'nuevo',
        source: _selectedSource ?? 'redes_sociales',
        score: _score,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.clientId != null) {
        await ClientService.updateClient(widget.clientId!, client);
      } else {
        await ClientService.createClient(client);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.clientId != null
                ? 'Cliente actualizado'
                : 'Cliente creado'),
          ),
        );
        ref.invalidate(clientsProvider);
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(clientOptionsProvider);

    if (!_isInitialized && widget.clientId != null) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId != null ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: optionsAsync.when(
        data: (options) => _buildForm(context, options),
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ClientOptions options) {
    // Inicializar valores por defecto si no están establecidos
    _selectedDocumentType ??= options.documentTypesList.isNotEmpty 
        ? options.documentTypesList.first 
        : 'DNI';
    _selectedType ??= options.clientTypesList.isNotEmpty 
        ? options.clientTypesList.first 
        : 'comprador';
    _selectedStatus ??= options.statusesList.isNotEmpty 
        ? options.statusesList.first 
        : 'nuevo';
    _selectedSource ??= options.sourcesList.isNotEmpty 
        ? options.sourcesList.first 
        : 'redes_sociales';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo *',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDocumentType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de documento *',
                  ),
                  items: options.documentTypesList
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(options.getDocumentTypeLabel(type)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDocumentType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _documentNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Número de documento *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de documento es requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
              ),
              child: Text(
                _birthDate != null
                    ? DateFormat('yyyy-MM-dd').format(_birthDate!)
                    : 'Seleccionar fecha',
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo de cliente *',
            ),
            items: options.clientTypesList
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(options.getClientTypeLabel(type)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado *',
            ),
            items: options.statusesList
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(options.getStatusLabel(status)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSource,
            decoration: const InputDecoration(
              labelText: 'Origen *',
            ),
            items: options.sourcesList
                .map((source) => DropdownMenuItem(
                      value: source,
                      child: Text(options.getSourceLabel(source)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSource = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: _score.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '$_score',
                onChanged: (value) {
                  setState(() {
                    _score = value.toInt();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notas',
            ),
          ),
          const SizedBox(height: 32),
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
                : Text(widget.clientId != null ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }
}

