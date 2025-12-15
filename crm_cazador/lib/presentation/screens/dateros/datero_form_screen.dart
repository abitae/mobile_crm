import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/datero_model.dart';
import '../../../data/services/datero_service.dart';
import '../../providers/datero_provider.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../data/services/document_service.dart';

/// Formulario para crear/editar datero
class DateroFormScreen extends ConsumerStatefulWidget {
  final int? dateroId;

  const DateroFormScreen({super.key, this.dateroId});

  @override
  ConsumerState<DateroFormScreen> createState() => _DateroFormScreenState();
}

class _DateroFormScreenState extends ConsumerState<DateroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dniController = TextEditingController();
  final _pinController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _bancoController = TextEditingController();
  final _cuentaController = TextEditingController();
  final _cciController = TextEditingController();

  bool _isSubmitting = false;
  bool _isActive = true;
  bool _initializedFromServer = false;
  bool _isSearchingDocument = false;

  @override
  void initState() {
    super.initState();
    if (widget.dateroId != null) {
      _loadDatero();
    }
  }

  Future<void> _loadDatero() async {
    try {
      final datero = await DateroService.getDatero(widget.dateroId!);
      if (!mounted) return;
      setState(() {
        _nameController.text = datero.name;
        _emailController.text = datero.email;
        _phoneController.text = datero.phone;
        _dniController.text = datero.dni;
        _ocupacionController.text = datero.ocupacion ?? '';
        _bancoController.text = datero.banco ?? '';
        _cuentaController.text = datero.cuentaBancaria ?? '';
        _cciController.text = datero.cciBancaria ?? '';
        _isActive = datero.isActive;
        _initializedFromServer = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datero: $e')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dniController.dispose();
    _pinController.dispose();
    _ocupacionController.dispose();
    _bancoController.dispose();
    _cuentaController.dispose();
    _cciController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Email por defecto basado en DNI si el usuario no ingresa uno
    final rawEmail = _emailController.text.trim();
    final rawDni = _dniController.text.trim();
    final sanitizedDni = rawDni.replaceAll(RegExp(r'[^0-9]'), '');
    final effectiveEmail = rawEmail.isEmpty
        ? '${sanitizedDni}@lotesenremate.pe'
        : rawEmail;

    final datero = DateroModel(
      id: widget.dateroId,
      name: _nameController.text.trim(),
      email: effectiveEmail,
      phone: _phoneController.text.trim(),
      dni: sanitizedDni, // Asegurar que solo tenga números
      pin: _pinController.text.trim().isEmpty ? null : _pinController.text.trim(),
      ocupacion: _ocupacionController.text.trim().isEmpty
          ? null
          : _ocupacionController.text.trim(),
      banco: _bancoController.text.trim().isEmpty
          ? null
          : _bancoController.text.trim(),
      cuentaBancaria: _cuentaController.text.trim().isEmpty
          ? null
          : _cuentaController.text.trim(),
      cciBancaria: _cciController.text.trim().isEmpty
          ? null
          : _cciController.text.trim(),
      isActive: _isActive,
    );

    try {
      if (widget.dateroId == null) {
        await DateroService.createDatero(datero);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datero creado correctamente')),
        );
      } else {
        await DateroService.updateDatero(widget.dateroId!, datero);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datero actualizado correctamente')),
        );
      }

      // Refrescar listado
      ref.read(daterosNotifierProvider).loadDateros(refresh: true);

      if (mounted) {
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
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _searchDocument() async {
    final documentNumber = _dniController.text.trim();

    if (documentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un número de DNI')),
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

        // Llenar nombre completo (similar a clientes)
        _nameController.text = data.fullName;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar DNI: $e'),
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.dateroId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Datero' : 'Nuevo Datero'),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmitting || (isEdit && !_initializedFromServer),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // DNI primero
                TextFormField(
                  controller: _dniController,
                  decoration: InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: const Icon(Icons.badge),
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
                            tooltip: 'Buscar datos por DNI',
                            onPressed:
                                _isSearchingDocument ? null : _searchDocument,
                          ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'El DNI es obligatorio';
                    }
                    if (trimmed.length != 8 ||
                        !RegExp(r'^[0-9]{8}$').hasMatch(trimmed)) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  readOnly: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio (busca primero por DNI)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return null; // opcional
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmed)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
                    }
                    if (value.trim().length > 20) {
                      return 'El teléfono no puede exceder 20 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN (6 dígitos)',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'El PIN es obligatorio';
                    }
                    if (trimmed.isNotEmpty &&
                        (trimmed.length != 6 ||
                            !RegExp(r'^[0-9]{6}$').hasMatch(trimmed))) {
                      return 'El PIN debe tener 6 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ocupacionController,
                  decoration: const InputDecoration(
                    labelText: 'Ocupación',
                    prefixIcon: Icon(Icons.work_outline),
                    helperText: 'Opcional',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _bancoController.text.isEmpty
                      ? null
                      : _bancoController.text,
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'BCP',
                      child: Text('BCP'),
                    ),
                    DropdownMenuItem(
                      value: 'NACION',
                      child: Text('NACIÓN'),
                    ),
                    DropdownMenuItem(
                      value: 'INTERBANK',
                      child: Text('INTERBANK'),
                    ),
                    DropdownMenuItem(
                      value: 'BBVA',
                      child: Text('BBVA'),
                    ),
                    DropdownMenuItem(
                      value: 'SCOTIABANK',
                      child: Text('Scotiabank'),
                    ),
                    DropdownMenuItem(
                      value: 'YAPE',
                      child: Text('Yape'),
                    ),
                    DropdownMenuItem(
                      value: 'OTRO',
                      child: Text('Otro'),
                    ),
                  ],
                  onChanged: (value) {
                    _bancoController.text = value ?? '';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cuentaController,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta bancaria',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cciController,
                  decoration: const InputDecoration(
                    labelText: 'CCI bancaria',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  title: const Text('Activo'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(isEdit ? 'Guardar Cambios' : 'Crear Datero'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


