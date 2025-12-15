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

/// Pantalla que muestra el QR de registro de clientes para el datero actual
class DateroQrScreen extends ConsumerStatefulWidget {
  const DateroQrScreen({super.key});

  @override
  ConsumerState<DateroQrScreen> createState() => _DateroQrScreenState();
}

class _DateroQrScreenState extends ConsumerState<DateroQrScreen> {
  final GlobalKey _qrKey = GlobalKey();

  String? get _registroUrl {
    final notifier = ref.read(profileNotifierProvider);
    final profileState = notifier.currentState;
    final profile = profileState.profile;
    if (profile == null) return null;

    final id = profile.id;
    return 'https://crm.lotesenremate.pe/clients/registro-datero/$id';
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

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(profileNotifierProvider);
    final profileState = notifier.currentState;
    final url = _registroUrl;

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (url == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Registro Clientes'),
        ),
        body: Center(
          child: Text(
            profileState.error ??
                'No se pudo obtener la información del datero.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Registro Clientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Comparte este código QR con tus clientes para que se registren en el sistema.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: url,
                  size: 220,
                  version: QrVersions.auto,
                  gapless: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              url,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _shareQr,
              icon: const Icon(Icons.share),
              label: const Text('Compartir QR'),
            ),
          ],
        ),
      ),
    );
  }
}


