class BleConstants {
  // Эти значения используются по умолчанию, если UUID не настроены
  static const String defaultServiceUuid = 'REPLACE_WITH_SERVICE_UUID';
  static const String defaultCharacteristicUuid = 'REPLACE_WITH_CHARACTERISTIC_UUID';

  static const String deviceNamePrefix = '';
  static const String fallbackDeviceName = 'Неизвестное устройство';
  static const int scanTimeoutSeconds = 5;

  static const int sampleBytes = 2;
  static const bool signedSamples = true;
  static const bool littleEndian = true;
  static const double sampleScale = 1.0;

  static String? _serviceUuid;
  static String? _characteristicUuid;

  static String get eegServiceUuid => _serviceUuid ?? defaultServiceUuid;
  static String get eegCharacteristicUuid =>
      _characteristicUuid ?? defaultCharacteristicUuid;

  static void setUuids(String? serviceUuid, String? characteristicUuid) {
    _serviceUuid = serviceUuid;
    _characteristicUuid = characteristicUuid;
  }

  static bool get isConfigured {
    return _serviceUuid != null &&
        _serviceUuid!.isNotEmpty &&
        _serviceUuid != defaultServiceUuid &&
        _characteristicUuid != null &&
        _characteristicUuid!.isNotEmpty &&
        _characteristicUuid != defaultCharacteristicUuid;
  }
}
