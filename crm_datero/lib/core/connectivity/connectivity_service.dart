import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityStatus>? _statusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<ConnectivityStatus> get onStatusChanged {
    _statusController ??= StreamController<ConnectivityStatus>.broadcast();
    return _statusController!.stream;
  }

  Future<void> initialize() async {
    final initialStatus = await checkConnectivity();
    _statusController?.add(initialStatus);
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _statusController?.add(_mapResultsToStatus(results));
    });
  }

  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _mapResultsToStatus(results);
    } catch (e) {
      return ConnectivityStatus.unknown;
    }
  }

  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.any((r) => r != ConnectivityResult.none)) return ConnectivityStatus.connected;
    return ConnectivityStatus.disconnected;
  }

  Future<bool> hasConnection() async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.connected;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController?.close();
    _statusController = null;
  }
}
