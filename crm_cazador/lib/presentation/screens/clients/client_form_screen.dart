import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../../data/services/client_service.dart';
import '../../../data/services/document_service.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/client_options.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/skeletons/client_form_skeleton.dart';
import '../../widgets/common/custom_snackbar.dart';
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
  final _titleController = TextEditingController(); // título opcional para notas iniciales (puede reutilizarse si se requiere)
  final _nameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  /// Modo de creación según backend: 'dni' o 'phone'
  String _createMode = 'dni';

  String? _selectedType;
  String? _selectedStatus;
  String? _selectedSource;
  int _score = 50;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSearchingDocument = false;

  bool get _isEditing => widget.clientId != null;

  String? _buildDuplicateOwnerMessage(Map<String, dynamic>? duplicateOwner) {
    if (duplicateOwner == null) return null;
    final ownerName = duplicateOwner['name']?.toString().trim();
    final field = duplicateOwner['field']?.toString().trim();
    if (ownerName == null || ownerName.isEmpty || field == null || field.isEmpty) {
      return null;
    }
    if (field == 'phone') {
      return 'Telefono registrado por "$ownerName"';
    }
    if (field == 'document_number') {
      return 'DNI registrado por "$ownerName"';
    }
    return '$field registrado por "$ownerName"';
  }

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
      _createMode = 'dni';
    }
    
    if (widget.clientId != null) {
      _loadClient();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
      _createMode = client.createMode ??
          (client.documentNumber.isNotEmpty ? 'dni' : 'phone');
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error al cargar cliente: $e',
          type: SnackbarType.error,
        );
        context.pop();
      }
    }
  }

  Future<void> _searchDocument() async {
    if (_createMode != 'dni') {
      CustomSnackbar.show(
        context,
        'La búsqueda de documento solo está disponible en modo DNI',
        type: SnackbarType.info,
      );
      return;
    }
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
          CustomSnackbar.show(
            context,
            'Datos encontrados y cargados exitosamente',
            type: SnackbarType.success,
          );
        }
      } else {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'No se encontró información para este DNI',
            type: SnackbarType.info,
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        // Mostrar mensaje de error con duración más larga para errores importantes
        final isClientRegistered = e.message.contains('registrado');
        CustomSnackbar.show(
          context,
          e.message,
          type: isClientRegistered ? SnackbarType.warning : SnackbarType.error,
          duration: isClientRegistered 
              ? const Duration(seconds: 5) 
              : const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error al buscar documento: $e',
          type: SnackbarType.error,
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🧾 [ClientForm] submit start mode=$_createMode isEdit=$_isEditing');
      // Sanitizar número de documento (solo números)
      final sanitizedDocumentNumber = _createMode == 'dni'
          ? _documentNumberController.text
              .trim()
              .replaceAll(RegExp(r'[^0-9]'), '')
          : '';

      // Sanitizar teléfono (solo números)
      final sanitizedPhone = _phoneController.text
          .trim()
          .replaceAll(RegExp(r'[^0-9]'), '');
      debugPrint('🧾 [ClientForm] sanitized phone=$sanitizedPhone dni=$sanitizedDocumentNumber');

      // Validaciones adicionales según create_mode
      if (_createMode == 'dni' && sanitizedDocumentNumber.length != 8) {
        CustomSnackbar.show(
          context,
          'El DNI debe tener 8 dígitos',
          type: SnackbarType.error,
        );
        return;
      }

      if (sanitizedPhone.length != 9 || !sanitizedPhone.startsWith('9')) {
        CustomSnackbar.show(
          context,
          'El teléfono debe tener 9 dígitos y comenzar con 9',
          type: SnackbarType.error,
        );
        return;
      }

      if (_birthDate == null) {
        CustomSnackbar.show(
          context,
          'La fecha de nacimiento es requerida',
          type: SnackbarType.error,
        );
        return;
      }

      final client = ClientModel(
        id: widget.clientId ?? 0,
        name: _nameController.text.trim(),
        documentType: 'DNI', // el backend espera este valor cuando hay DNI
        documentNumber: sanitizedDocumentNumber,
        phone: sanitizedPhone, // obligatorio y normalizado
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
        createMode: _createMode,
      );

      if (widget.clientId != null) {
        debugPrint('🧾 [ClientForm] validate (edit) payload=${client.toCreateJson()}');
        await ClientService.validateClient(client);
        debugPrint('🧾 [ClientForm] update client id=${widget.clientId}');
        await ClientService.updateClient(widget.clientId!, client);
        // Invalidar el provider del cliente específico para refrescar su detalle
        ref.invalidate(clientProvider(widget.clientId!));
      } else {
        // Validar con el backend antes de crear
        debugPrint('🧾 [ClientForm] validate (create) payload=${client.toCreateJson()}');
        await ClientService.validateClient(client);
        debugPrint('🧾 [ClientForm] create client');
        await ClientService.createClient(client);
      }

      if (mounted) {
        CustomSnackbar.show(
          context,
          widget.clientId != null ? 'Cliente actualizado' : 'Cliente creado',
          type: SnackbarType.success,
        );
        // Recargar la lista de clientes de forma reactiva
        ref.read(clientsNotifierProvider).loadClients(refresh: true);
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        final duplicateOwner = e.errors?['duplicate_owner'] as Map<String, dynamic>?;
        final duplicateMessage = _buildDuplicateOwnerMessage(duplicateOwner);
        debugPrint('🧾 [ClientForm] api error=${e.message} errors=${e.errors}');
        CustomSnackbar.show(
          context,
          duplicateMessage ?? e.message,
          type: duplicateOwner != null ? SnackbarType.warning : SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('🧾 [ClientForm] unexpected error=$e');
        CustomSnackbar.show(
          context,
          'Error: $e',
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

  Future<void> _selectDate(FormFieldState<DateTime> field) async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return SafeArea(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
      field.didChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(clientOptionsProvider);

    if (!_isInitialized && widget.clientId != null) {
      return const Scaffold(
        body: ClientFormSkeleton(),
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

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            12.0,
            12.0,
            12.0,
            12.0 + MediaQuery.of(context).viewInsets.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
          // Sección: Modo de creación
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Modo de creación',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'dni',
                          groupValue: _createMode,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('DNI'),
                          onChanged: _isEditing
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _createMode = value;
                                  });
                                },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'phone',
                          groupValue: _createMode,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Teléfono'),
                          onChanged: _isEditing
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _createMode = value;
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _createMode == 'dni'
                        ? 'Se validará y autocompletará los datos del cliente usando su DNI.'
                        : 'Puede registrar un cliente solo con número de celular, sin DNI.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 4),
                    Text(
                      'El modo de creación no puede cambiarse en edición.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sección: Información de Documento
          if (_createMode == 'dni')
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, color: colorScheme.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Documento de Identidad',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                              helperText: '8 dígitos',
                              prefixIcon: const Icon(Icons.credit_card),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              helperStyle: const TextStyle(fontSize: 11, height: 1.1),
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
          const SizedBox(height: 10),
          // Sección: Información Personal
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Información Personal',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo *',
                      prefixIcon: Icon(Icons.person),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                  const SizedBox(height: 12),
                  FormField<DateTime>(
                    validator: (_) {
                      if (_birthDate == null) {
                        return 'La fecha de nacimiento es requerida';
                      }
                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () => _selectDate(field),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento *',
                            prefixIcon: const Icon(Icons.calendar_today),
                            errorText: field.errorText,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            _birthDate != null
                                ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                                : 'Seleccionar fecha',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone),
                      helperText: '9 dígitos, empieza en 9',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      helperStyle: TextStyle(fontSize: 11, height: 1.1),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es requerido';
                      }
                      final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (sanitized.length != 9 || !sanitized.startsWith('9')) {
                        return 'El teléfono debe tener 9 dígitos y comenzar en 9';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.location_on),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sección: Información Comercial
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_outlined, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Información Comercial',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de cliente *',
                      prefixIcon: Icon(Icons.category),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado *',
                      prefixIcon: Icon(Icons.info_outline),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSource,
                    decoration: const InputDecoration(
                      labelText: 'Origen *',
                      prefixIcon: Icon(Icons.source),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Score',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '$_score',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: theme.sliderTheme.copyWith(
                          trackHeight: 2,
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sección: Notas
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note_outlined, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Notas Adicionales',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      hintText: 'Información adicional sobre el cliente...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }
}

