import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/headset_device.dart';
import '../../data/repositories/headset_repository.dart';
import '../../core/utils/error_handler.dart';

class HeadsetViewModel extends ChangeNotifier {
  final HeadsetRepository _repository;
  StreamSubscription<HeadsetDevice>? _connectionSubscription;

  List<HeadsetDevice> _devices = [];
  HeadsetDevice? _connectedDevice;
  bool _isScanning = false;
  String? _lastError;

  HeadsetViewModel(this._repository) {
    // Слушаем изменения статуса подключения из репозитория.
    _connectionSubscription = _repository.connectionStream.listen((device) {
      _connectedDevice = device;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }

  List<HeadsetDevice> get devices => List.unmodifiable(_devices);
  HeadsetDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnected =>
      _connectedDevice?.connectionStatus == ConnectionStatus.connected;
  String? get errorMessage => _lastError;

  Future<void> scanDevices() async {
    // Обновляем список доступных BLE-устройств.
    _isScanning = true;
    notifyListeners();

    try {
      _devices = await _repository.scanDevices();
      _lastError = null;
    } catch (e) {
      _lastError = ErrorHandler.formatBluetoothError(e);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> connect(HeadsetDevice device) async {
    // Показываем состояние "подключение..." в UI.
    _connectedDevice = device.copyWith(
      connectionStatus: ConnectionStatus.connecting,
    );
    notifyListeners();
    try {
      await _repository.connect(device);
      _lastError = null;
      if (_connectedDevice?.connectionStatus == ConnectionStatus.connecting) {
        _connectedDevice = device.copyWith(
          connectionStatus: ConnectionStatus.connected,
        );
      }
      notifyListeners();
    } catch (e) {
      _lastError = ErrorHandler.formatBluetoothError(e);
      _connectedDevice = device.copyWith(
        connectionStatus: ConnectionStatus.error,
      );
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _repository.disconnect();
      _connectedDevice = null;
      _lastError = null;
    } catch (e) {
      _lastError = ErrorHandler.formatBluetoothError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadLastConnectedDevice() async {
    _connectedDevice = await _repository.getLastConnectedDevice();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
