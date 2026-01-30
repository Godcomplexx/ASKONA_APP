import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/headset_view_model.dart';
import '../viewmodels/recording_view_model.dart';
import '../viewmodels/storage_view_model.dart';
import '../widgets/connection_status.dart';
import '../widgets/recording_status.dart';
import '../widgets/storage_indicator.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/eeg_line_chart.dart';
import '../../domain/entities/headset_device.dart' show ConnectionStatus;
import '../../core/constants/app_constants.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  int _lastStorageAlertLevel = 0;

  @override
  void initState() {
    super.initState();
    // load current session and list of files after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecordingViewModel>().loadCurrentSession();
        context.read<StorageViewModel>().loadFiles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись ЭЭГ'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentLocation: GoRouterState.of(context).uri.path,
      ),
      body: Consumer3<HeadsetViewModel, RecordingViewModel, StorageViewModel>(
        builder:
            (context, headsetViewModel, recordingViewModel, storageViewModel, child) {
          if (recordingViewModel.errorMessage != null) {
            // show recording errors to user
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final message = recordingViewModel.errorMessage!;
                recordingViewModel.clearError();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            });
          }

          _maybeShowStorageWarning(context, storageViewModel.availableSpace);

          final isConnected = headsetViewModel.isConnected;
          final isRecording = recordingViewModel.isRecording;
          final currentSession = recordingViewModel.currentSession;

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
                          status: headsetViewModel
                                  .connectedDevice?.connectionStatus ??
                              ConnectionStatus.disconnected,
                          deviceName: headsetViewModel.connectedDevice?.name,
                        ),
                        const SizedBox(height: 16),
                        RecordingStatusWidget(
                          state: recordingViewModel.state,
                          duration: currentSession?.duration,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'График сигнала',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: EegLineChart(data: recordingViewModel.chartData),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StorageIndicatorWidget(
                  usedBytes: storageViewModel.totalSize,
                  totalBytes: storageViewModel.totalSize +
                      storageViewModel.availableSpace,
                  availableBytes: storageViewModel.availableSpace,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: !isConnected
                      ? null
                      : () {
                          // Кнопка старт/стоп записи.
                          if (isRecording) {
                            recordingViewModel.stopRecording();
                          } else {
                            recordingViewModel.startRecording();
                          }
                        },
                  icon: Icon(isRecording ? Icons.stop : Icons.play_arrow),
                  label:
                      Text(isRecording ? 'Остановить запись' : 'Начать запись'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isRecording ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _maybeShowStorageWarning(BuildContext context, int availableBytes) {
    final availableMb = availableBytes ~/ (1024 * 1024);
    if (availableMb <= AppConstants.criticalThresholdMB &&
        _lastStorageAlertLevel != 2) {
      _lastStorageAlertLevel = 2;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Критически мало свободного места')),
          );
        }
      });
      return;
    }
    if (availableMb <= AppConstants.warningThresholdMB &&
        _lastStorageAlertLevel != 1) {
      _lastStorageAlertLevel = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Мало свободного места')),
          );
        }
      });
      return;
    }
    if (availableMb > AppConstants.warningThresholdMB) {
      _lastStorageAlertLevel = 0;
    }
  }
}
