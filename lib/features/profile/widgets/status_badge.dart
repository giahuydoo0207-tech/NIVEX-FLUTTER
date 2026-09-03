import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, this.isSuccess = true, super.key});

  final String label;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final bgColor = isSuccess ? theme.successSoft : theme.surfaceSubtle;
    final fgColor = isSuccess ? theme.success : theme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSuccess) ...[
            Icon(Icons.check_circle_rounded, size: 13, color: fgColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: fgColor,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
