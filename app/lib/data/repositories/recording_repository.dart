import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/recording_file.dart';
import '../../domain/entities/recording_session.dart';
import '../../domain/entities/recording_settings.dart';
import '../services/bluetooth_service.dart';
import '../services/file_service.dart';

abstract class RecordingRepository {
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<RecordingSession?> getCurrentSession();
  Future<List<RecordingSession>> getAllSessions();
  Stream<List<double>> get dataStream;
  void updateSettings(RecordingSettings settings);
  void dispose();
}

class RecordingRepositoryImpl implements RecordingRepository {
  final BluetoothService _bluetoothService;
  final FileService _fileService;
  RecordingSession? _currentSession;
  RecordingFile? _currentFile;
  int _currentPart = 1;
  RecordingSettings _settings = const RecordingSettings();
  Timer? _rotationTimer;
  Timer? _flushTimer;
  final _buffer = StringBuffer();
  final _dataController = StreamController<List<double>>.broadcast();
  StreamSubscription<List<double>>? _bluetoothSubscription;

  RecordingRepositoryImpl(this._bluetoothService, this._fileService) {
    // Подписываемся на поток данных BLE.
    _bluetoothSubscription = _bluetoothService.getDataStream().listen((data) {
      _dataController.add(data);
      if (_currentSession != null && _currentFile != null) {
        _appendCsvLine(data);
      }
    });
  }

  @override
  Future<void> startRecording() async {
    if (_currentSession == null) {
      // Создаем новую сессию и первый файл записи.
      _currentSession = RecordingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
      );
      _currentPart = 1;
      _currentFile =
          await _fileService.createFile(_currentSession!.id, _currentPart);
      _currentSession = _currentSession!.copyWith(
        filePaths: [_currentFile!.path],
      );
      _startRotationTimer();
      _startFlushTimer();
    }
  }

  @override
  Future<void> stopRecording() async {
    if (_currentSession != null) {
      // Сбрасываем буфер и закрываем текущий файл.
      await _flushBuffer();
      _rotationTimer?.cancel();
      _flushTimer?.cancel();
      _currentSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        status: SessionStatus.completed,
      );
      if (_currentFile != null) {
        await _fileService.closeFile(_currentFile!.path);
        _currentFile = null;
      }
      _currentSession = null;
    }
  }

  @override
  Future<RecordingSession?> getCurrentSession() async {
    return _currentSession;
  }

  @override
  Future<List<RecordingSession>> getAllSessions() async {
    // TODO: Load from storage (история сессий пока не реализована).
    return [];
  }

  @override
  Stream<List<double>> get dataStream => _dataController.stream;

  @override
  void updateSettings(RecordingSettings settings) {
    _settings = settings;
    if (_currentSession != null) {
      _startRotationTimer();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _flushTimer?.cancel();
    _bluetoothSubscription?.cancel();
    _dataController.close();
  }

  void _startRotationTimer() {
    _rotationTimer?.cancel();
    final minutes = _settings.fileSplitIntervalMinutes;
    _rotationTimer = Timer(Duration(minutes: minutes), _rotateFile);
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_buffer.isNotEmpty) {
        _flushBuffer();
      }
    });
  }

  Future<void> _rotateFile() async {
    if (_currentSession == null) return;
    await _flushBuffer();
    if (_currentFile != null) {
      await _fileService.closeFile(_currentFile!.path);
    }
    _currentPart += 1;
    _currentFile =
        await _fileService.createFile(_currentSession!.id, _currentPart);
    _currentSession = _currentSession!.copyWith(
      filePaths: [..._currentSession!.filePaths, _currentFile!.path],
    );
    _startRotationTimer();
  }

  void _appendCsvLine(List<double> data) {
    if (data.isEmpty) return;
    final timestamp = DateTime.now().toIso8601String();
    final payload = data.join(AppConstants.csvDelimiter);
    _buffer.write('$timestamp${AppConstants.csvDelimiter}$payload\n');
  }

  Future<void> _flushBuffer() async {
    if (_currentFile == null || _buffer.isEmpty) return;
    final data = _buffer.toString();
    _buffer.clear();
    await _fileService.writeData(_currentFile!.path, data);
  }
}
