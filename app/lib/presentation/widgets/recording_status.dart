import 'package:flutter/material.dart';
import '../viewmodels/recording_view_model.dart';
import '../../core/utils/extensions.dart';

class RecordingStatusWidget extends StatelessWidget {
  final RecordingState state;
  final Duration? duration;

  const RecordingStatusWidget({
    super.key,
    required this.state,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    IconData icon;
    String text;

    switch (state) {
      case RecordingState.recording:
        color = Colors.red;
        icon = Icons.fiber_manual_record;
        text = duration != null ? 'Запись: ${duration!.format()}' : 'Запись...';
        break;
      case RecordingState.paused:
        color = Colors.orange;
        icon = Icons.pause_circle;
        text = 'Пауза';
        break;
      case RecordingState.error:
        color = Colors.red;
        icon = Icons.error;
        text = 'Ошибка записи';
        break;
      case RecordingState.idle:
      default:
        color = Colors.grey;
        icon = Icons.stop_circle;
        text = 'Не записывается';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
