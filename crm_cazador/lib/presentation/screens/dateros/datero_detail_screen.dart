import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/datero_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/skeletons/datero_detail_skeleton.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../../data/models/datero_model.dart';

/// Pantalla de detalle de datero
class DateroDetailScreen extends ConsumerStatefulWidget {
  final int dateroId;

  const DateroDetailScreen({
    super.key,
    required this.dateroId,
  });

  @override
  ConsumerState<DateroDetailScreen> createState() => _DateroDetailScreenState();
}

class _DateroDetailScreenState extends ConsumerState<DateroDetailScreen> {
  final GlobalKey _qrKey = GlobalKey();

  String _generateQrData(DateroModel datero) {
    final qrData = {
      'id': datero.id,
      'name': datero.name,
      'email': datero.email,
      'phone': datero.phone,
      'dni': datero.dni,
      'type': 'datero',
    };
    return jsonEncode(qrData);
  }

  Future<void> _shareQr(DateroModel datero) async {
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
      final file = File('${tempDir.path}/qr_datero_${datero.id}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Código QR del datero: ${datero.name}',
        subject: 'QR Datero - ${datero.name}',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        'No se pudo compartir el código QR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateroAsync = ref.watch(dateroProvider(widget.dateroId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Datero'),
        actions: [
          dateroAsync.when(
            data: (datero) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/dateros/${widget.dateroId}/edit');
                } else if (value == 'share_qr') {
                  dateroAsync.whenData((datero) {
                    _shareQr(datero);
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share_qr',
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, size: 20),
                      SizedBox(width: 8),
                      Text('Compartir QR'),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: dateroAsync.when(
        data: (datero) => _buildDetail(context, ref, datero),
        loading: () => DateroDetailSkeleton(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(dateroProvider(widget.dateroId));
          },
        ),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    DateroModel datero,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dateroProvider(widget.dateroId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      datero.name.isNotEmpty
                          ? datero.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          datero.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              datero.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  datero.isActive ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              datero.isActive ? 'Activo' : 'Inactivo',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: datero.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildQrSection(context, datero),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Información básica',
            [
              _buildRow(context, Icons.badge, 'DNI', datero.dni),
              _buildRow(context, Icons.phone, 'Teléfono', datero.phone),
              _buildRow(context, Icons.email, 'Email', datero.email),
              if (datero.ocupacion != null && datero.ocupacion!.isNotEmpty)
                _buildRow(context, Icons.work_outline, 'Ocupación', datero.ocupacion!),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Información bancaria',
            [
              _buildRow(
                context,
                Icons.account_balance,
                'Banco',
                datero.banco ?? '-',
              ),
              _buildRow(
                context,
                Icons.credit_card,
                'Cuenta bancaria',
                datero.cuentaBancaria ?? '-',
              ),
              _buildRow(
                context,
                Icons.numbers,
                'CCI',
                datero.cciBancaria ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (datero.lider != null)
            _buildSection(
              context,
              'Líder',
              [
                _buildRow(
                  context,
                  Icons.person,
                  'Nombre',
                  (datero.lider?['name'] as String?) ?? '-',
                ),
                _buildRow(
                  context,
                  Icons.email,
                  'Email',
                  (datero.lider?['email'] as String?) ?? '-',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection(BuildContext context, DateroModel datero) {
    final theme = Theme.of(context);
    final qrData = _generateQrData(datero);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Código QR',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareQr(datero),
                  tooltip: 'Compartir QR',
                ),
              ],
            ),
            const Divider(height: 24),
            Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: qrData,
                    size: 200,
                    version: QrVersions.auto,
                    gapless: true,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Escanea este código para obtener la información del datero',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


