import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Estado de conectividad
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Servicio para detectar estado de conectividad
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityStatus>? _statusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream de cambios de conectividad
  Stream<ConnectivityStatus> get onStatusChanged {
    _statusController ??= StreamController<ConnectivityStatus>.broadcast();
    return _statusController!.stream;
  }

  /// Inicializar el servicio
  Future<void> initialize() async {
    // Verificar estado inicial
    final initialStatus = await checkConnectivity();
    _statusController?.add(initialStatus);

    // Escuchar cambios
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapResultsToStatus(results);
      _statusController?.add(status);
    });
  }

  /// Verificar estado actual de conectividad
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapResultsToStatus(results);
    } catch (e) {
      return ConnectivityStatus.unknown;
    }
  }

  /// Mapear resultados de Connectivity a ConnectivityStatus
  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    // Si hay al menos un resultado que no sea none, está conectado
    if (results.any((result) => result != ConnectivityResult.none)) {
      return ConnectivityStatus.connected;
    }
    return ConnectivityStatus.disconnected;
  }

  /// Verificar si hay conexión activa
  Future<bool> hasConnection() async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.connected;
  }

  /// Dispose del servicio
  void dispose() {
    _subscription?.cancel();
    _statusController?.close();
    _statusController = null;
  }
}
