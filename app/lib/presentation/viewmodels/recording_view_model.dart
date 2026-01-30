import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/recording_session.dart';
import '../../domain/entities/recording_settings.dart';
import '../../data/repositories/recording_repository.dart';
import '../../core/utils/error_handler.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  error,
}

class RecordingViewModel extends ChangeNotifier {
  static const _prefSplitInterval = 'settings_split_interval';
  static const _prefAllowBackground = 'settings_allow_background';
  static const _prefAutoStart = 'settings_auto_start';

  final RecordingRepository _repository;
  StreamSubscription<List<double>>? _dataSubscription;

  RecordingState _state = RecordingState.idle;
  RecordingSession? _currentSession;
  List<double> _latestData = [];
  final List<double> _chartBuffer = [];
  DateTime _lastChartNotify = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _maxChartPoints = 500;
  static const Duration _chartNotifyInterval = Duration(milliseconds: 50);
  RecordingSettings _settings = const RecordingSettings();
  String? _lastError;

  RecordingViewModel(this._repository) {
    // Подписка на поток данных для графика.
    _dataSubscription = _repository.dataStream.listen((data) {
      _latestData = data;
      _appendChartData(data);
      final now = DateTime.now();
      if (now.difference(_lastChartNotify) >= _chartNotifyInterval) {
        _lastChartNotify = now;
        notifyListeners();
      }
    });
    // Загружаем настройки пользователя из SharedPreferences.
    _loadSettings();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }

  RecordingState get state => _state;
  RecordingSession? get currentSession => _currentSession;
  List<double> get latestData => List.unmodifiable(_latestData);
  List<double> get chartData => List.unmodifiable(_chartBuffer);
  RecordingSettings get settings => _settings;
  bool get isRecording => _state == RecordingState.recording;
  String? get errorMessage => _lastError;

  Future<void> startRecording() async {
    if (_state == RecordingState.recording) return;

    try {
      await _repository.startRecording();
      _currentSession = await _repository.getCurrentSession();
      _state = RecordingState.recording;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _state = RecordingState.error;
      _lastError = ErrorHandler.formatError(e);
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (_state != RecordingState.recording) return;

    try {
      await _repository.stopRecording();
      _currentSession = await _repository.getCurrentSession();
      _state = RecordingState.idle;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _state = RecordingState.error;
      _lastError = ErrorHandler.formatError(e);
      notifyListeners();
    }
  }

  void updateSettings(RecordingSettings settings) {
    _settings = settings;
    _repository.updateSettings(settings);
    _saveSettings();
    notifyListeners();
    // TODO: Реализовать поведение allowBackgroundRecording и autoStartOnConnect.
  }

  Future<void> loadSettings() async {
    await _loadSettings();
    notifyListeners();
  }

  Future<void> loadCurrentSession() async {
    _currentSession = await _repository.getCurrentSession();
    if (_currentSession != null) {
      _state = RecordingState.recording;
    }
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void _appendChartData(List<double> data) {
    // Храним последние N точек для графика.
    if (data.isEmpty) return;
    _chartBuffer.addAll(data);
    if (_chartBuffer.length > _maxChartPoints) {
      _chartBuffer.removeRange(0, _chartBuffer.length - _maxChartPoints);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = RecordingSettings(
      fileSplitIntervalMinutes:
          prefs.getInt(_prefSplitInterval) ?? _settings.fileSplitIntervalMinutes,
      allowBackgroundRecording: prefs.getBool(_prefAllowBackground) ??
          _settings.allowBackgroundRecording,
      autoStartOnConnect:
          prefs.getBool(_prefAutoStart) ?? _settings.autoStartOnConnect,
    );
    _repository.updateSettings(_settings);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefSplitInterval, _settings.fileSplitIntervalMinutes);
    await prefs.setBool(_prefAllowBackground, _settings.allowBackgroundRecording);
    await prefs.setBool(_prefAutoStart, _settings.autoStartOnConnect);
  }
}
