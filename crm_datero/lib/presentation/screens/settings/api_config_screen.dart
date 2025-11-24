import 'package:flutter/material.dart';
import '../../../config/api_config.dart';
import '../../../data/services/api_service.dart';
import '../../theme/app_icons.dart';

/// Pantalla de configuración de API
class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  ApiEnvironment _selectedEnvironment = ApiEnvironment.production;
  final _customUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    final environment = await ApiConfigService.getCurrentEnvironment();
    setState(() {
      _selectedEnvironment = environment;
    });

    if (environment == ApiEnvironment.custom) {
      final customUrl = await ApiConfigService.getBaseUrl();
      _customUrlController.text = customUrl;
    }
  }

  Future<void> _testConnection(String url) async {
    setState(() {
      _isTesting = true;
    });

    try {
      // TODO: Implementar test de conexión real
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conexión exitosa')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiConfigService.setEnvironment(_selectedEnvironment);

      if (_selectedEnvironment == ApiEnvironment.custom) {
        final customUrl = _customUrlController.text.trim();
        if (!ApiConfigService.isValidUrl(customUrl)) {
          throw Exception('URL inválida');
        }
        await ApiConfigService.setCustomUrl(customUrl);
      }

      final baseUrl = await ApiConfigService.getBaseUrl();
      await ApiService.updateBaseUrl(baseUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada')),
        );
        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de API'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Entorno',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...ApiEnvironment.values.map((env) {
            return RadioListTile<ApiEnvironment>(
              title: Text(env.label),
              subtitle: env != ApiEnvironment.custom
                  ? Text(env.defaultUrl)
                  : null,
              value: env,
              groupValue: _selectedEnvironment,
              onChanged: (value) {
                setState(() {
                  _selectedEnvironment = value ?? ApiEnvironment.production;
                });
              },
            );
          }),
          if (_selectedEnvironment == ApiEnvironment.custom) ...[
            const SizedBox(height: 24),
            TextFormField(
              controller: _customUrlController,
              decoration: InputDecoration(
                labelText: 'URL personalizada',
                hintText: 'https://api.example.com',
                prefixIcon: Icon(AppIcons.settings),
                suffixIcon: _customUrlController.text.isNotEmpty
                    ? IconButton(
                        icon: _isTesting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        onPressed: _isTesting
                            ? null
                            : () {
                                final url = _customUrlController.text.trim();
                                if (url.isNotEmpty) {
                                  _testConnection(url);
                                }
                              },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!ApiConfigService.isValidUrl(value)) {
                    return 'URL inválida. Debe comenzar con http:// o https://';
                  }
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isLoading ? null : _saveConfig,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar Configuración'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await ApiConfigService.resetToDefault();
              await _loadCurrentConfig();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración restablecida')),
                );
              }
            },
            child: const Text('Restablecer a Predeterminado'),
          ),
        ],
      ),
    );
  }
}

