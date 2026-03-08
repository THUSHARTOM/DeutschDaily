import 'package:flutter/material.dart';

/// Shows the user's daily login streak.
class StreakDisplay extends StatelessWidget {
  final int streak;

  const StreakDisplay({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasStreak ? Colors.orange.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStreak ? Icons.local_fire_department : Icons.local_fire_department_outlined,
            color: hasStreak ? Colors.deepOrange : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasStreak ? Colors.deepOrange.shade800 : Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
