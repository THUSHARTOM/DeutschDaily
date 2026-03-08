import 'package:flutter/material.dart';

/// A toggleable chip for learning keywords in a story.
class KeywordChip extends StatelessWidget {
  final String keyword;
  final bool isLearned;
  final ValueChanged<bool> onToggle;

  const KeywordChip({
    super.key,
    required this.keyword,
    required this.isLearned,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(keyword),
      selected: isLearned,
      onSelected: onToggle,
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green.shade700,
      labelStyle: TextStyle(
        color: isLearned ? Colors.green.shade900 : null,
        fontWeight: isLearned ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
