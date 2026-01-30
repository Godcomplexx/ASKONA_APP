import '../../domain/entities/recording_session.dart';

class RecordingSessionModel extends RecordingSession {
  const RecordingSessionModel({
    required super.id,
    required super.startTime,
    super.endTime,
    super.status,
    super.filePaths,
  });

  factory RecordingSessionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSessionModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
      filePaths: (json['filePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.name,
      'filePaths': filePaths,
    };
  }

  factory RecordingSessionModel.fromEntity(RecordingSession session) {
    return RecordingSessionModel(
      id: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      status: session.status,
      filePaths: session.filePaths,
    );
  }

  RecordingSession toEntity() {
    return RecordingSession(
      id: id,
      startTime: startTime,
      endTime: endTime,
      status: status,
      filePaths: filePaths,
    );
  }
}
