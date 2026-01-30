import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'presentation/viewmodels/headset_view_model.dart';
import 'presentation/viewmodels/recording_view_model.dart';
import 'presentation/viewmodels/storage_view_model.dart';
import 'data/repositories/headset_repository.dart';
import 'data/repositories/recording_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/services/bluetooth_service.dart';
import 'data/services/file_service.dart';

// Глобальные ссылки на провайдеры, чтобы корректно освобождать ресурсы.
HeadsetViewModel? _headsetViewModel;
RecordingViewModel? _recordingViewModel;

void main() {
  // Создаем сервисы (низкоуровневая работа с BLE и файлами).
  final bluetoothService = BluetoothServiceImpl();
  final fileService = FileServiceImpl();
  // Создаем репозитории (бизнес-логика поверх сервисов).
  final headsetRepository = HeadsetRepositoryImpl(bluetoothService);
  final recordingRepository = RecordingRepositoryImpl(bluetoothService, fileService);
  final storageRepository = StorageRepositoryImpl(fileService);
  
  // Создаем провайдеры (состояние для UI).
  _headsetViewModel = HeadsetViewModel(headsetRepository);
  _recordingViewModel = RecordingViewModel(recordingRepository);
  final storageViewModel = StorageViewModel(storageRepository);

  // Запускаем приложение.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _headsetViewModel!),
        ChangeNotifierProvider.value(value: _recordingViewModel!),
        ChangeNotifierProvider.value(value: storageViewModel),
      ],
      child: const MainApp(), 
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose провайдеров при закрытии приложения
    _headsetViewModel?.dispose();
    _recordingViewModel?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      // При закрытии или паузе приложения освобождаем ресурсы.
      _headsetViewModel?.dispose();
      _recordingViewModel?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ЭЭГ Запись',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
