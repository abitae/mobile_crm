import 'package:flutter/material.dart';
import '../../../data/services/reservation_service.dart';
import '../../../core/exceptions/api_exception.dart';

/// Diálogo para cancelar una reserva
class ReservationCancelDialog extends StatefulWidget {
  final int reservationId;
  final VoidCallback? onCanceled;

  const ReservationCancelDialog({
    super.key,
    required this.reservationId,
    this.onCanceled,
  });

  @override
  State<ReservationCancelDialog> createState() =>
      _ReservationCancelDialogState();
}

class _ReservationCancelDialogState extends State<ReservationCancelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ReservationService.cancelReservation(
        widget.reservationId,
        _noteController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCanceled?.call();
        Navigator.of(context).pop(true);
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
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Cancelar Reserva'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa una nota de cancelación. Esta acción no se puede deshacer.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota de cancelación',
                  hintText: 'Mínimo 10 caracteres',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La nota es obligatoria';
                  }
                  if (value.trim().length < 10) {
                    return 'La nota debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleCancel,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Confirmar Cancelación'),
        ),
      ],
    );
  }
}

