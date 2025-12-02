import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/project_provider.dart';
import '../../../data/services/reservation_service.dart';
import '../../../data/services/project_service.dart';
import '../../../core/exceptions/api_exception.dart';

/// Pantalla para confirmar una reserva con imagen
class ReservationConfirmScreen extends ConsumerStatefulWidget {
  final int reservationId;

  const ReservationConfirmScreen({
    super.key,
    required this.reservationId,
  });

  @override
  ConsumerState<ReservationConfirmScreen> createState() =>
      _ReservationConfirmScreenState();
}

class _ReservationConfirmScreenState
    extends ConsumerState<ReservationConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservationAmountController = TextEditingController();
  final _reservationPercentageController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _paymentReferenceController = TextEditingController();

  File? _selectedImage;
  DateTime? _reservationDate;
  DateTime? _expirationDate;
  String? _paymentStatus;
  int? _projectId;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  @override
  void dispose() {
    _reservationAmountController.dispose();
    _reservationPercentageController.dispose();
    _paymentMethodController.dispose();
    _paymentReferenceController.dispose();
    super.dispose();
  }

  Future<void> _loadReservation() async {
    try {
      final reservation =
          await ReservationService.getReservation(widget.reservationId);
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
      _paymentStatus = reservation.paymentStatus;
      _projectId = reservation.projectId;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      if (source == ImageSource.gallery) {
        await _pickImage();
      } else {
        await _takePhoto();
      }
    }
  }

  Future<void> _handleConfirm() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una imagen del comprobante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final additionalData = <String, dynamic>{};
      if (_reservationDate != null) {
        additionalData['reservation_date'] =
            _reservationDate!.toIso8601String().split('T')[0];
      }
      if (_expirationDate != null) {
        additionalData['expiration_date'] =
            _expirationDate!.toIso8601String().split('T')[0];
      }
      if (_reservationAmountController.text.isNotEmpty) {
        additionalData['reservation_amount'] =
            double.parse(_reservationAmountController.text);
      }
      if (_reservationPercentageController.text.isNotEmpty) {
        additionalData['reservation_percentage'] =
            double.parse(_reservationPercentageController.text);
      }
      if (_paymentMethodController.text.isNotEmpty) {
        additionalData['payment_method'] = _paymentMethodController.text;
      }
      if (_paymentStatus != null && _paymentStatus!.isNotEmpty) {
        additionalData['payment_status'] = _paymentStatus;
      }
      if (_paymentReferenceController.text.isNotEmpty) {
        additionalData['payment_reference'] = _paymentReferenceController.text;
      }

      final confirmedReservation = await ReservationService.confirmReservation(
        widget.reservationId,
        _selectedImage!.path,
        additionalData: additionalData.isEmpty ? null : additionalData,
      );

      if (mounted) {
        // Invalidar y refrescar la reserva individual
        ref.invalidate(reservationProvider(widget.reservationId));
        
        // Refrescar la lista de reservas
        ref.read(reservationsNotifierProvider).refreshReservations();
        
        // Refrescar las unidades disponibles del proyecto
        // Usar el projectId de la reserva confirmada (puede ser diferente al inicial)
        // o el guardado inicialmente como respaldo
        final projectIdToRefresh = confirmedReservation.projectId > 0 
            ? confirmedReservation.projectId 
            : (_projectId ?? 0);
        if (projectIdToRefresh > 0) {
          // Invalidar el caché de unidades del proyecto
          ProjectService.invalidateUnitsCache(projectIdToRefresh);
          
          // Refrescar el provider de unidades si existe
          try {
            final unitsNotifier = ref.read(projectUnitsNotifierProvider(projectIdToRefresh));
            await unitsNotifier.loadUnits(refresh: true);
          } catch (e) {
            // Si el provider no existe (no está siendo usado), solo invalidamos el caché
            print('⚠️ [ReservationConfirm] Provider de unidades no disponible: $e');
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva confirmada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
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

    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Reserva'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen del comprobante
              _buildSectionHeader('Comprobante de Pago', Icons.image_outlined),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_selectedImage != null) ...[
                        Image.file(
                          _selectedImage!,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.change_circle),
                          label: const Text('Cambiar Imagen'),
                        ),
                      ] else ...[
                        const Icon(Icons.image_outlined, size: 64),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Seleccionar Imagen'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La imagen es obligatoria para confirmar la reserva',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fechas (opcionales para actualizar)
              _buildSectionHeader('Fechas (Opcional)', Icons.calendar_today_outlined),
              ListTile(
                title: const Text('Fecha de Reserva'),
                subtitle: Text(_reservationDate != null
                    ? dateFormat.format(_reservationDate!)
                    : 'No seleccionada'),
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
                title: const Text('Fecha de Vencimiento'),
                subtitle: Text(_expirationDate != null
                    ? dateFormat.format(_expirationDate!)
                    : 'No seleccionada'),
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

              // Montos (opcionales para actualizar)
              _buildSectionHeader('Montos (Opcional)', Icons.attach_money),
              TextFormField(
                controller: _reservationAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto de Reserva',
                  border: OutlineInputBorder(),
                  prefixText: 'S/ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reservationPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Información de Pago (opcional para actualizar)
              _buildSectionHeader('Información de Pago (Opcional)', Icons.payment),
              DropdownButtonFormField<String>(
                value: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado de Pago',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'parcial', child: Text('Parcial')),
                  DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentMethodController,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                  hintText: 'Transferencia, Efectivo, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentReferenceController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de Pago',
                  border: OutlineInputBorder(),
                  hintText: 'Número de operación, código, etc.',
                ),
              ),
              const SizedBox(height: 24),

              // Botón de confirmar
              FilledButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar Reserva'),
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
}

