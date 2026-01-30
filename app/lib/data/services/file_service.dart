import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/recording_file.dart';

abstract class FileService {
  Future<String> getRecordingsDirectory();
  Future<RecordingFile> createFile(String sessionId, int partNumber);
  Future<void> writeData(String filePath, String data);
  Future<void> closeFile(String filePath);
  Future<List<RecordingFile>> listFiles();
  Future<void> deleteFile(String path);
  Future<int> getFileSize(String path);
}

class FileServiceImpl implements FileService {
  @override
  Future<String> getRecordingsDirectory() async {
    // Папка для CSV-файлов внутри документов приложения.
    final baseDir = await getApplicationDocumentsDirectory();
    final recordingsDir =
        Directory('${baseDir.path}/${AppConstants.recordingsDirectoryName}');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir.path;
  }

  @override
  Future<RecordingFile> createFile(String sessionId, int partNumber) async {
    // Создаем новый CSV-файл и пишем заголовок.
    final now = DateTime.now();
    final dir = await getRecordingsDirectory();
    final timestamp = _formatDateTime(now);
    final fileName =
        '${timestamp}_${sessionId}_part$partNumber${AppConstants.fileExtension}';
    final path = '$dir/$fileName';
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(
        '${AppConstants.csvHeader}\n',
        mode: FileMode.append,
      );
    }
    return RecordingFile(
      path: path,
      startTime: now,
      endTime: now,
      size: await file.length(),
      isCompleted: false,
    );
  }

  @override
  Future<void> writeData(String filePath, String data) async {
    final file = File(filePath);
    await file.writeAsString(data, mode: FileMode.append);
  }

  @override
  Future<void> closeFile(String filePath) async {
    // Using writeAsString with append mode doesn't keep open handles.
    await File(filePath).lastModified();
  }

  @override
  Future<List<RecordingFile>> listFiles() async {
    // Сканируем папку записей и формируем список файлов.
    final dir = Directory(await getRecordingsDirectory());
    if (!await dir.exists()) {
      return [];
    }
    final files = await dir
        .list()
        .where(
          (entity) =>
              entity is File && entity.path.endsWith(AppConstants.fileExtension),
        )
        .cast<File>()
        .toList();

    final results = <RecordingFile>[];
    for (final file in files) {
      final stat = await file.stat();
      final parsedTime = _parseDateTimeFromFileName(file.path);
      final start = parsedTime ?? stat.modified;
      results.add(
        RecordingFile(
          path: file.path,
          startTime: start,
          endTime: stat.modified,
          size: stat.size,
          isCompleted: true,
        ),
      );
    }
    results.sort((a, b) => b.startTime.compareTo(a.startTime));
    return results;
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<int> getFileSize(String path) async {
    final file = File(path);
    return file.existsSync() ? file.lengthSync() : 0;
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year$month$day' '_' '$hour$minute';
  }

  DateTime? _parseDateTimeFromFileName(String path) {
    final name = path.split('/').last;
    final match = RegExp(r'^(\\d{8}_\\d{4})_').firstMatch(name);
    if (match == null) return null;
    final raw = match.group(1);
    if (raw == null || raw.length != 13) return null;
    final year = int.tryParse(raw.substring(0, 4));
    final month = int.tryParse(raw.substring(4, 6));
    final day = int.tryParse(raw.substring(6, 8));
    final hour = int.tryParse(raw.substring(9, 11));
    final minute = int.tryParse(raw.substring(11, 13));
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute);
  }
}
