class AppConstants {
  // File naming format: YYYYMMDD_HHMM_sessionId_partN.ext
  static const String recordingsDirectoryName = 'eeg_recordings';
  static const String fileExtension = '.csv';
  static const String dateTimeFormat = 'yyyyMMdd_HHmm';
  
  // File split intervals (in minutes)
  static const List<int> splitIntervals = [30, 60];
  static const int defaultSplitInterval = 30;
  
  // Storage thresholds
  static const int warningThresholdMB = 100; // Warn when less than 100MB free
  static const int criticalThresholdMB = 50; // Critical when less than 50MB free
  
  // CSV format
  static const String csvHeader = 'timestamp,channel1,channel2,channel3,channel4';
  static const String csvDelimiter = ',';
}
