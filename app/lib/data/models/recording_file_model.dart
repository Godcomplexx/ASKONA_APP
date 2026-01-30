import '../../domain/entities/recording_file.dart';

class RecordingFileModel extends RecordingFile {
  const RecordingFileModel({
    required super.path,
    required super.startTime,
    required super.endTime,
    required super.size,
    super.isCompleted,
  });

  factory RecordingFileModel.fromJson(Map<String, dynamic> json) {
    return RecordingFileModel(
      path: json['path'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      size: json['size'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'size': size,
      'isCompleted': isCompleted,
    };
  }

  factory RecordingFileModel.fromEntity(RecordingFile file) {
    return RecordingFileModel(
      path: file.path,
      startTime: file.startTime,
      endTime: file.endTime,
      size: file.size,
      isCompleted: file.isCompleted,
    );
  }

  RecordingFile toEntity() {
    return RecordingFile(
      path: path,
      startTime: startTime,
      endTime: endTime,
      size: size,
      isCompleted: isCompleted,
    );
  }
}
