import 'package:flutter/material.dart';
import '../../domain/entities/headset_device.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionStatus status;
  final String? deviceName;

  const ConnectionStatusWidget({
    super.key,
    required this.status,
    this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    IconData icon;
    String text;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.bluetooth_connected;
        text = deviceName != null ? 'Подключено: $deviceName' : 'Подключено';
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        icon = Icons.bluetooth_searching;
        text = 'Подключение...';
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        icon = Icons.bluetooth_disabled;
        text = 'Ошибка подключения';
        break;
      case ConnectionStatus.disconnected:
      default:
        color = Colors.grey;
        icon = Icons.bluetooth_disabled;
        text = 'Не подключено';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
