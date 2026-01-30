import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/ble_constants.dart';
import '../../domain/entities/headset_device.dart';
import '../services/bluetooth_service.dart';

abstract class HeadsetRepository {
  Future<List<HeadsetDevice>> scanDevices();
  Future<void> connect(HeadsetDevice device);
  Future<void> disconnect();
  Future<HeadsetDevice?> getLastConnectedDevice();
  Stream<HeadsetDevice> get connectionStream;
  void dispose();
}

class HeadsetRepositoryImpl implements HeadsetRepository {
  static const _prefDeviceId = 'last_device_id';
  static const _prefDeviceName = 'last_device_name';
  static const _prefDeviceAddress = 'last_device_address';

  final BluetoothService _bluetoothService;
  HeadsetDevice? _connectedDevice;
  final _connectionController = StreamController<HeadsetDevice>.broadcast();

  HeadsetRepositoryImpl(this._bluetoothService);

  @override
  Future<List<HeadsetDevice>> scanDevices() async {
    if (!await _bluetoothService.isBluetoothEnabled()) {
      throw Exception(
        'Bluetooth выключен. Включите Bluetooth в настройках устройства.',
      );
    }
    await _bluetoothService.requestPermissions();
    final devices = <HeadsetDevice>[];
    final stream = _bluetoothService.scanForDevices();
    final subscription = stream.listen((results) {
      devices
        ..clear()
        ..addAll(results);
    });

    await Future.delayed(
      const Duration(seconds: BleConstants.scanTimeoutSeconds),
    );
    await subscription.cancel();
    return devices;
  }

  @override
  Future<void> connect(HeadsetDevice device) async {
    _connectedDevice =
        device.copyWith(connectionStatus: ConnectionStatus.connecting);
    _connectionController.add(_connectedDevice!);
    await _bluetoothService.connectToDevice(device);
    _connectedDevice =
        device.copyWith(connectionStatus: ConnectionStatus.connected);
    _connectionController.add(_connectedDevice!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefDeviceId, device.id);
    await prefs.setString(_prefDeviceName, device.name);
    await prefs.setString(_prefDeviceAddress, device.address);
  }

  @override
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
    if (_connectedDevice != null) {
      _connectedDevice = _connectedDevice!.copyWith(
        connectionStatus: ConnectionStatus.disconnected,
      );
      _connectionController.add(_connectedDevice!);
      _connectedDevice = null;
    }
  }

  @override
  Future<HeadsetDevice?> getLastConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefDeviceId);
    final name = prefs.getString(_prefDeviceName);
    final address = prefs.getString(_prefDeviceAddress);
    if (id == null || name == null || address == null) {
      return null;
    }
    return HeadsetDevice(
      id: id,
      name: name,
      address: address,
      connectionStatus: ConnectionStatus.disconnected,
    );
  }

  @override
  Stream<HeadsetDevice> get connectionStream => _connectionController.stream;

  @override
  void dispose() {
    _connectionController.close();
  }
}
