class RecordingFile {
  final String path;
  final DateTime startTime;
  final DateTime endTime;
  final int size;
  final bool isCompleted;

  const RecordingFile({
    required this.path,
    required this.startTime,
    required this.endTime,
    required this.size,
    this.isCompleted = false,
  });

  Duration get duration => endTime.difference(startTime);

  String get fileName {
    final parts = path.split('/');
    return parts.last;
  }

  RecordingFile copyWith({
    String? path,
    DateTime? startTime,
    DateTime? endTime,
    int? size,
    bool? isCompleted,
  }) {
    return RecordingFile(
      path: path ?? this.path,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      size: size ?? this.size,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
