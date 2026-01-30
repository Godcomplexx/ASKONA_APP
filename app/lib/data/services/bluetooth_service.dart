import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/ble_constants.dart';
import '../../domain/entities/headset_device.dart';

abstract class BluetoothService {
  Future<bool> isBluetoothEnabled();
  Future<void> requestPermissions();
  Stream<List<HeadsetDevice>> scanForDevices();
  Future<void> connectToDevice(HeadsetDevice device);
  Future<void> disconnect();
  Stream<List<double>> getDataStream();
}

class BluetoothServiceImpl implements BluetoothService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  StreamSubscription<List<int>>? _notifySubscription;
  // Поток данных ЭЭГ (список чисел), который читает слой записи/графика.
  final _dataController = StreamController<List<double>>.broadcast();

  @override
  Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  @override
  Future<void> requestPermissions() async {
    // На Android нужны отдельные разрешения для сканирования и подключения.
    if (defaultTargetPlatform != TargetPlatform.android) {
      await Permission.bluetooth.request();
      return;
    }

    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];

    final statusMap = await permissions.request();
    final denied = statusMap.values
        .any((status) => status.isDenied || status.isPermanentlyDenied);
    if (denied) {
      throw Exception(
        'Необходимо разрешение на использование Bluetooth. Проверьте настройки приложения.',
      );
    }

    // На Android BLE-сканирование требует геолокации.
    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }
  }

  @override
  Stream<List<HeadsetDevice>> scanForDevices() {
    final controller = StreamController<List<HeadsetDevice>>();
    final devices = <String, HeadsetDevice>{};

    // Стартуем сканирование на заданное время.
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: BleConstants.scanTimeoutSeconds),
    );

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        // Если устройство не имеет имени, показываем заглушку.
        final deviceName = result.device.name.isNotEmpty
            ? result.device.name
            : BleConstants.fallbackDeviceName;
        if (BleConstants.deviceNamePrefix.isNotEmpty &&
            !deviceName.startsWith(BleConstants.deviceNamePrefix)) {
          continue;
        }
        // TODO: Если нужно, фильтровать по сервисному UUID на этапе сканирования.
        devices[result.device.id.id] = HeadsetDevice(
          id: result.device.id.id,
          name: deviceName,
          address: result.device.id.id,
          rssi: result.rssi,
        );
      }
      controller.add(devices.values.toList());
    }, onError: controller.addError);

    controller.onCancel = () async {
      await subscription.cancel();
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }
    };

    return controller.stream;
  }

  @override
  Future<void> connectToDevice(HeadsetDevice device) async {
    // TODO: Проверять BleConstants.isConfigured и давать понятную ошибку, если UUID не заданы.
    await disconnect();
    final bleDevice = BluetoothDevice.fromId(device.id);
    await bleDevice.connect();
    _connectedDevice = bleDevice;

    // Ищем конкретный сервис/характеристику ЭЭГ.
    final services = await bleDevice.discoverServices();
    final serviceUuid = Guid(BleConstants.eegServiceUuid);
    final characteristicUuid = Guid(BleConstants.eegCharacteristicUuid);

    BluetoothCharacteristic? target;
    for (final service in services) {
      if (service.uuid == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == characteristicUuid) {
            target = characteristic;
            break;
          }
        }
      }
    }

    if (target == null) {
      throw Exception(
        'Характеристика ЭЭГ не найдена. Проверьте совместимость устройства.',
      );
    }

    // Подписываемся на уведомления и превращаем байты в список чисел.
    _dataCharacteristic = target;
    await target.setNotifyValue(true);
    _notifySubscription = target.onValueReceived.listen((payload) {
      final parsed = _parsePayload(payload);
      if (parsed.isNotEmpty) {
        _dataController.add(parsed);
      }
    });
  }

  @override
  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    if (_dataCharacteristic != null) {
      try {
        await _dataCharacteristic?.setNotifyValue(false);
      } catch (_) {
        // ignore errors during disconnect
      }
    }
    _dataCharacteristic = null;
    if (_connectedDevice != null) {
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
    }
  }

  @override
  Stream<List<double>> getDataStream() {
    return _dataController.stream;
  }

  List<double> _parsePayload(List<int> payload) {
    // Преобразование байтов в список значений каналов.
    if (payload.isEmpty) return [];
    final data = Uint8List.fromList(payload);
    final bytesPerSample = BleConstants.sampleBytes;
    if (bytesPerSample <= 0 || data.length < bytesPerSample) return [];

    final byteData = ByteData.sublistView(data);
    final values = <double>[];
    for (var offset = 0;
        offset + bytesPerSample <= data.length;
        offset += bytesPerSample) {
      final raw = BleConstants.signedSamples
          ? (BleConstants.littleEndian
              ? byteData.getInt16(offset, Endian.little)
              : byteData.getInt16(offset, Endian.big))
          : (BleConstants.littleEndian
              ? byteData.getUint16(offset, Endian.little)
              : byteData.getUint16(offset, Endian.big));
      values.add(raw * BleConstants.sampleScale);
    }
    return values;
  }
}
