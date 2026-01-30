import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/headset_view_model.dart';
import '../widgets/connection_status.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../domain/entities/headset_device.dart' show ConnectionStatus;

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});
  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // after first frame load last connected device and start scanning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HeadsetViewModel>().loadLastConnectedDevice();
        context.read<HeadsetViewModel>().scanDevices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подключение устройства'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HeadsetViewModel>().scanDevices(),
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: () => context.read<HeadsetViewModel>().disconnect(),
            tooltip: 'Отключиться',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentLocation: GoRouterState.of(context).uri.path,
      ),
      body: Consumer<HeadsetViewModel>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            // Показываем ошибки подключения/сканирования пользователю.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final message = provider.errorMessage!;
                provider.clearError();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            });
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ConnectionStatusWidget(
                          status: provider.connectedDevice?.connectionStatus ??
                              ConnectionStatus.disconnected,
                          deviceName: provider.connectedDevice?.name,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Найденные устройства',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Нажмите на устройство для подключения',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: provider.devices.isEmpty
                      ? Center(
                          child: Text(
                            provider.isScanning
                                ? 'Поиск устройств...'
                                : 'Устройства не найдены',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.devices.length,
                          itemBuilder: (context, index) {
                            final device = provider.devices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.headset),
                                title: Text(device.name),
                                subtitle: Text(device.address),
                                trailing: device.rssi != null
                                    ? Text('${device.rssi} dBm')
                                    : null,
                                onTap: () => provider.connect(device),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
