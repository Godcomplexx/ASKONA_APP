import '../../domain/entities/recording_settings.dart';

class RecordingSettingsModel extends RecordingSettings {
  const RecordingSettingsModel({
    super.fileSplitIntervalMinutes = 30,
    super.allowBackgroundRecording = false,
    super.autoStartOnConnect = false,
  });

  factory RecordingSettingsModel.fromJson(Map<String, dynamic> json) {
    return RecordingSettingsModel(
      fileSplitIntervalMinutes:
          json['fileSplitIntervalMinutes'] as int? ?? 30,
      allowBackgroundRecording:
          json['allowBackgroundRecording'] as bool? ?? false,
      autoStartOnConnect: json['autoStartOnConnect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileSplitIntervalMinutes': fileSplitIntervalMinutes,
      'allowBackgroundRecording': allowBackgroundRecording,
      'autoStartOnConnect': autoStartOnConnect,
    };
  }

  factory RecordingSettingsModel.fromEntity(RecordingSettings settings) {
    return RecordingSettingsModel(
      fileSplitIntervalMinutes: settings.fileSplitIntervalMinutes,
      allowBackgroundRecording: settings.allowBackgroundRecording,
      autoStartOnConnect: settings.autoStartOnConnect,
    );
  }

  RecordingSettings toEntity() {
    return RecordingSettings(
      fileSplitIntervalMinutes: fileSplitIntervalMinutes,
      allowBackgroundRecording: allowBackgroundRecording,
      autoStartOnConnect: autoStartOnConnect,
    );
  }
}
