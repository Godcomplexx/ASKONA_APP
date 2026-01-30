enum SessionStatus {
  active,
  completed,
  error,
}

class RecordingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final List<String> filePaths;

  const RecordingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.status = SessionStatus.active,
    this.filePaths = const [],
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  RecordingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
    List<String>? filePaths,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      filePaths: filePaths ?? this.filePaths,
    );
  }
}
