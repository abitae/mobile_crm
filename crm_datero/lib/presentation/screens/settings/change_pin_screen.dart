import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../theme/app_icons.dart';

/// Pantalla de cambio de PIN
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.changePin(
        currentPin: _currentPinController.text,
        newPin: _newPinController.text,
        newPinConfirmation: _confirmPinController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _currentPinController.clear();
        _newPinController.clear();
        _confirmPinController.clear();

        // Regresar a la pantalla anterior
        Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar PIN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                AppIcons.lock,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Cambiar tu PIN',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu PIN actual y el nuevo PIN',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _currentPinController,
                keyboardType: TextInputType.number,
                obscureText: _obscureCurrentPin,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'PIN actual',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPin = !_obscureCurrentPin;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                  helperText: '6 dígitos numéricos',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El PIN actual es obligatorio';
                  }
                  if (value.length != 6) {
                    return 'El PIN debe tener 6 dígitos';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'El PIN solo debe contener números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPinController,
                keyboardType: TextInputType.number,
                obscureText: _obscureNewPin,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Nuevo PIN',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPin = !_obscureNewPin;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                  helperText: '6 dígitos numéricos',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nuevo PIN es obligatorio';
                  }
                  if (value.length != 6) {
                    return 'El PIN debe tener 6 dígitos';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'El PIN solo debe contener números';
                  }
                  if (value == _currentPinController.text) {
                    return 'El nuevo PIN debe ser diferente al actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: _obscureConfirmPin,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Confirmar nuevo PIN',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La confirmación de PIN es obligatoria';
                  }
                  if (value != _newPinController.text) {
                    return 'Los PINs no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _changePin,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Cambiar PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

