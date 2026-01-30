import 'package:flutter/material.dart';
import '../../core/utils/extensions.dart';

class StorageIndicatorWidget extends StatelessWidget {
  final int usedBytes;
  final int totalBytes;
  final int? availableBytes;

  const StorageIndicatorWidget({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
    this.availableBytes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final used = usedBytes;
    final total = totalBytes;
    final percentage = total > 0 ? (used / total) * 100 : 0.0;

    Color color;
    if (percentage >= 90) {
      color = Colors.red;
    } else if (percentage >= 70) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Хранилище',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${used.formatBytes()} / ${total.formatBytes()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        if (availableBytes != null) ...[
          const SizedBox(height: 4),
          Text(
            'Свободно: ${availableBytes!.formatBytes()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
