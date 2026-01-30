import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/recording_view_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentLocation: GoRouterState.of(context).uri.path,
      ),
      body: Consumer<RecordingViewModel>(
        builder: (context, recordingViewModel, child) {
          final settings = recordingViewModel.settings;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Интервал разбиения файла',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...AppConstants.splitIntervals.map((interval) {
                        return RadioListTile<int>(
                          title: Text('$interval минут'),
                          value: interval,
                          groupValue: settings.fileSplitIntervalMinutes,
                          onChanged: (value) {
                            if (value != null) {
                              recordingViewModel.updateSettings(
                                settings.copyWith(
                                  fileSplitIntervalMinutes: value,
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Разрешить запись в фоне'),
                  subtitle: const Text(
                    'Позволяет продолжать запись при сворачивании приложения',
                  ),
                  value: settings.allowBackgroundRecording,
                  onChanged: (value) {
                    recordingViewModel.updateSettings(
                      settings.copyWith(allowBackgroundRecording: value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  title: const Text('Автозапуск при подключении'),
                  subtitle: const Text(
                    'Автоматически начинать запись при подключении устройства',
                  ),
                  value: settings.autoStartOnConnect,
                  onChanged: (value) {
                    recordingViewModel.updateSettings(
                      settings.copyWith(autoStartOnConnect: value),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
