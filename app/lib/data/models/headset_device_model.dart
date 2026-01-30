import '../../domain/entities/headset_device.dart';

class HeadsetDeviceModel extends HeadsetDevice {
  const HeadsetDeviceModel({
    required super.id,
    required super.name,
    required super.address,
    super.rssi,
    super.connectionStatus,
  });

  factory HeadsetDeviceModel.fromJson(Map<String, dynamic> json) {
    return HeadsetDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rssi: json['rssi'] as int?,
      connectionStatus: ConnectionStatus.values.firstWhere(
        (e) => e.name == json['connectionStatus'],
        orElse: () => ConnectionStatus.disconnected,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rssi': rssi,
      'connectionStatus': connectionStatus.name,
    };
  }

  factory HeadsetDeviceModel.fromEntity(HeadsetDevice device) {
    return HeadsetDeviceModel(
      id: device.id,
      name: device.name,
      address: device.address,
      rssi: device.rssi,
      connectionStatus: device.connectionStatus,
    );
  }

  HeadsetDevice toEntity() {
    return HeadsetDevice(
      id: id,
      name: name,
      address: address,
      rssi: rssi,
      connectionStatus: connectionStatus,
    );
  }
}
