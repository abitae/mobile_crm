import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/loading_indicator.dart';

/// Pantalla de perfil del datero
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _qrKey = GlobalKey();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bancoController = TextEditingController();
  final _cuentaBancariaController = TextEditingController();
  final _cciBancariaController = TextEditingController();

  bool _isEditing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bancoController.dispose();
    _cuentaBancariaController.dispose();
    _cciBancariaController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final notifier = ref.read(profileNotifierProvider);
    final profileState = notifier.currentState;
    if (profileState.profile != null) {
      final profile = profileState.profile!;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _bancoController.text = profile.banco ?? '';
      _cuentaBancariaController.text = profile.cuentaBancaria ?? '';
      _cciBancariaController.text = profile.cciBancaria ?? '';
      _isInitialized = true;
    }
  }

  String? get _registroUrl {
    final notifier = ref.read(profileNotifierProvider);
    final profileState = notifier.currentState;
    final profile = profileState.profile;
    if (profile == null) return null;

    return 'https://crm.lotesenremate.pe/clients/registro-datero/${profile.id}';
  }

  Future<void> _shareQr() async {
    try {
      final renderObject = _qrKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('QR no disponible');
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_registro_datero.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Escanea este código para registrarte como cliente en LER Datero.',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo compartir el código QR'),
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(profileNotifierProvider).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          banco: _bancoController.text.trim().isEmpty
              ? null
              : _bancoController.text.trim(),
          cuentaBancaria: _cuentaBancariaController.text.trim().isEmpty
              ? null
              : _cuentaBancariaController.text.trim(),
          cciBancaria: _cciBancariaController.text.trim().isEmpty
              ? null
              : _cciBancariaController.text.trim(),
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
        _loadProfileData();
      } else {
        final profileState = ref.read(profileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.error ?? 'Error al actualizar perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(profileNotifierProvider);
    final profileState = notifier.currentState;

    if (!_isInitialized && profileState.profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfileData();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Editar',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadProfileData();
              },
              tooltip: 'Cancelar',
            ),
        ],
      ),
      body: profileState.isLoading && profileState.profile == null
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (profileState.profile != null) ...[
                      // QR de registro + compartir
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'QR de registro de clientes',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              RepaintBoundary(
                                key: _qrKey,
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  child: QrImageView(
                                    data: _registroUrl ?? '',
                                    size: 200,
                                    version: QrVersions.auto,
                                    gapless: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_registroUrl != null)
                                Text(
                                  _registroUrl!,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _shareQr,
                                icon: const Icon(Icons.share),
                                label: const Text('Compartir QR'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Información editable
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información Personal',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El email es obligatorio';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Información bancaria
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información Bancaria',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Opcional - Para el pago de comisiones',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _bancoController,
                                enabled: _isEditing,
                                decoration: const InputDecoration(
                                  labelText: 'Banco',
                                  prefixIcon: Icon(Icons.account_balance),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cuentaBancariaController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Número de Cuenta',
                                  prefixIcon: Icon(Icons.account_balance_wallet),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cciBancariaController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'CCI',
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: profileState.isLoading ? null : _handleSave,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: profileState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Guardar Cambios'),
                        ),
                      ],
                    ] else if (profileState.error != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profileState.error!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                ref.read(profileNotifierProvider).loadProfile();
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

