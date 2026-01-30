import 'package:flutter/foundation.dart';
import '../../domain/entities/recording_file.dart';
import '../../data/repositories/storage_repository.dart';

class StorageViewModel extends ChangeNotifier {
  final StorageRepository _repository;

  List<RecordingFile> _files = [];
  int _totalSize = 0;
  int _availableSpace = 0;
  bool _isLoading = false;

  StorageViewModel(this._repository);

  List<RecordingFile> get files => List.unmodifiable(_files);
  int get totalSize => _totalSize;
  int get availableSpace => _availableSpace;
  bool get isLoading => _isLoading;

  double get usedSpacePercentage {
    final total = _totalSize + _availableSpace;
    if (total == 0) return 0;
    return (_totalSize / total) * 100;
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _files = await _repository.getAllFiles();
      _totalSize = await _repository.getTotalSize();
      _availableSpace = await _repository.getAvailableSpace();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFile(String path) async {
    await _repository.deleteFile(path);
    await loadFiles();
  }

  Future<void> deleteAllFiles() async {
    await _repository.deleteAllFiles();
    await loadFiles();
  }

  Future<void> refresh() async {
    await loadFiles();
  }
}
