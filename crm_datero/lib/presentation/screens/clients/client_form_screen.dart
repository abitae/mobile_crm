import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../../data/services/document_service.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/client_options.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/skeleton_loader.dart';
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

  String? _selectedType;
  String? _selectedStatus;
  String? _selectedSource;
  int _score = 50;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSearchingDocument = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto para nuevos clientes
    if (widget.clientId == null) {
      _selectedType = 'comprador';
      _selectedStatus = 'nuevo';
      _selectedSource = 'referidos';
      _score = 50;
      _notesController.text = 'Nota: ';
    }
    
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
      _notesController.text = client.notes ?? 'Nota: ';
      // Tipo de documento siempre será DNI
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
      // Sanitizar número de documento (solo números)
      final sanitizedDocumentNumber = _documentNumberController.text
          .trim()
          .replaceAll(RegExp(r'[^0-9]'), '');

      final client = ClientModel(
        id: widget.clientId ?? 0,
        name: _nameController.text.trim(),
        documentType: 'DNI', // Siempre DNI
        documentNumber: sanitizedDocumentNumber,
        phone: _phoneController.text.trim(), // Obligatorio
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        birthDate: _birthDate,
        type: _selectedType ?? 'comprador',
        status: _selectedStatus ?? 'nuevo',
        source: _selectedSource ?? 'referidos',
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
        // Recargar la lista de clientes
        ref.read(clientsNotifierProvider).loadClients(refresh: true);
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

  Future<void> _searchDocument() async {
    final documentNumber = _documentNumberController.text.trim();
    
    if (documentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un número de documento')),
      );
      return;
    }

    // Validar que tenga 8 dígitos
    final sanitizedNumber = documentNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El DNI debe tener 8 dígitos')),
      );
      return;
    }

    setState(() {
      _isSearchingDocument = true;
    });

    try {
      final result = await DocumentService.searchDocument(
        documentType: 'dni',
        documentNumber: sanitizedNumber,
      );

      if (result.found && result.data != null) {
        final data = result.data!;
        
        // Llenar nombre completo
        _nameController.text = data.fullName;
        
        // Llenar fecha de nacimiento si está disponible
        // La fecha viene en formato "dd/MM/yyyy" (ej: "14/01/1986")
        if (data.fechaNacimiento != null && data.fechaNacimiento!.isNotEmpty) {
          try {
            setState(() {
              // Intentar parsear formato "dd/MM/yyyy"
              _birthDate = DateFormat('dd/MM/yyyy').parse(data.fechaNacimiento!);
            });
          } catch (e) {
            // Si falla, intentar otros formatos comunes
            try {
              setState(() {
                _birthDate = DateFormat('yyyy-MM-dd').parse(data.fechaNacimiento!);
              });
            } catch (e2) {
              // Ignorar error de parsing de fecha
            }
          }
        }

        // Llenar dirección si está disponible
        if (data.api?.result != null) {
          final address = data.api!.result!.fullAddress;
          if (address.isNotEmpty) {
            _addressController.text = address;
          }
        } else if (result.ubigeo != null && result.ubigeo!.text.isNotEmpty) {
          _addressController.text = result.ubigeo!.text;
        }

        // El tipo de documento siempre es DNI

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos encontrados y cargados exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontró información para este DNI'),
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        // Mostrar mensaje de error con duración más larga para errores importantes
        final isClientRegistered = e.message.contains('registrado');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: isClientRegistered 
                ? Colors.orange 
                : Theme.of(context).colorScheme.error,
            duration: isClientRegistered 
                ? const Duration(seconds: 5) 
                : const Duration(seconds: 3),
            action: isClientRegistered
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar documento: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingDocument = false;
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
        body: LoadingIndicator(
          useSkeleton: true,
          skeletonType: SkeletonType.form,
        ),
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
    _selectedType ??= 'comprador';
    _selectedStatus ??= 'nuevo';
    _selectedSource ??= 'referidos';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección: Información de Documento
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Documento de Identidad',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Número de documento con botón de búsqueda (PRIMERO)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _documentNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Número de DNI *',
                            hintText: '12345678',
                            helperText: 'Ingrese 8 dígitos',
                            prefixIcon: const Icon(Icons.credit_card),
                            suffixIcon: _isSearchingDocument
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.search),
                                    tooltip: 'Buscar datos del DNI',
                                    onPressed: _isSearchingDocument ? null : _searchDocument,
                                  ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El número de documento es requerido';
                            }
                            final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (sanitized.length != 8) {
                              return 'El DNI debe tener 8 dígitos';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sección: Información Personal
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Información Personal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo *',
                      prefixIcon: Icon(Icons.person),
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
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _birthDate != null
                            ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Email inválido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sección: Información Comercial
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Información Comercial',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de cliente *',
                      prefixIcon: Icon(Icons.category),
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
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado *',
                      prefixIcon: Icon(Icons.info_outline),
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
                    value: _selectedSource,
                    decoration: const InputDecoration(
                      labelText: 'Origen *',
                      prefixIcon: Icon(Icons.source),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Score',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            '$_score',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sección: Notas
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Notas Adicionales',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      hintText: 'Información adicional sobre el cliente...',
                    ),
                  ),
                ],
              ),
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

