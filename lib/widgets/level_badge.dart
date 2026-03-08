import 'package:flutter/material.dart';

/// A small colored badge displaying the German CEFR level (A1, A2, B1, B2).
class LevelBadge extends StatelessWidget {
  final String level;

  const LevelBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    Color getLevelColor() {
      switch (level) {
        case 'A1':
          return Colors.green.shade600;
        case 'A2':
          return Colors.blue.shade600;
        case 'B1':
          return Colors.orange.shade600;
        case 'B2':
          return Colors.red.shade600;
        default:
          return Colors.grey.shade600;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getLevelColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getLevelColor().withValues(alpha: 0.5)),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: getLevelColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
