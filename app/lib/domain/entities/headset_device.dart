enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class HeadsetDevice {
  final String id;
  final String name;
  final String address;
  final int? rssi;
  final ConnectionStatus connectionStatus;

  const HeadsetDevice({
    required this.id,
    required this.name,
    required this.address,
    this.rssi,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  HeadsetDevice copyWith({
    String? id,
    String? name,
    String? address,
    int? rssi,
    ConnectionStatus? connectionStatus,
  }) {
    return HeadsetDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rssi: rssi ?? this.rssi,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}
