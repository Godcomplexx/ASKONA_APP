import '../../domain/entities/recording_file.dart';
import '../services/file_service.dart';

abstract class StorageRepository {
  Future<List<RecordingFile>> getAllFiles();
  Future<int> getTotalSize();
  Future<int> getAvailableSpace();
  Future<void> deleteFile(String path);
  Future<void> deleteAllFiles();
}

class StorageRepositoryImpl implements StorageRepository {
  final FileService _fileService;
  final List<RecordingFile> _files = [];

  StorageRepositoryImpl(this._fileService);

  @override
  Future<List<RecordingFile>> getAllFiles() async {
    final files = await _fileService.listFiles();
    _files
      ..clear()
      ..addAll(files);
    return List.unmodifiable(_files);
  }

  @override
  Future<int> getTotalSize() async {
    if (_files.isEmpty) {
      await getAllFiles();
    }
    return _files.fold<int>(0, (sum, file) => sum + file.size);
  }

  @override
  Future<int> getAvailableSpace() async {
    // TODO: Replace with platform-specific free space lookup if needed.
    // Сейчас это заглушка, чтобы UI мог показать шкалу.
    return 1024 * 1024 * 1024; // 1GB placeholder
  }

  @override
  Future<void> deleteFile(String path) async {
    await _fileService.deleteFile(path);
    _files.removeWhere((file) => file.path == path);
  }

  @override
  Future<void> deleteAllFiles() async {
    final files = await getAllFiles();
    for (final file in files) {
      await _fileService.deleteFile(file.path);
    }
    _files.clear();
  }
}
