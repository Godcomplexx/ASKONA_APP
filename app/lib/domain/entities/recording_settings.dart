class RecordingSettings {
  final int fileSplitIntervalMinutes;
  final bool allowBackgroundRecording;
  final bool autoStartOnConnect;

  const RecordingSettings({
    this.fileSplitIntervalMinutes = 30,
    this.allowBackgroundRecording = false,
    this.autoStartOnConnect = false,
  });

  RecordingSettings copyWith({
    int? fileSplitIntervalMinutes,
    bool? allowBackgroundRecording,
    bool? autoStartOnConnect,
  }) {
    return RecordingSettings(
      fileSplitIntervalMinutes:
          fileSplitIntervalMinutes ?? this.fileSplitIntervalMinutes,
      allowBackgroundRecording:
          allowBackgroundRecording ?? this.allowBackgroundRecording,
      autoStartOnConnect: autoStartOnConnect ?? this.autoStartOnConnect,
    );
  }
}
