import 'package:flutter/material.dart';
import '../models/story.dart';
import 'level_badge.dart';

/// A card displaying a story's title, level, category, and reading time.
class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final bool isCompleted;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LevelBadge(level: story.level),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20)
                ],
              ),
              const SizedBox(height: 12),
              Text(
                story.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    story.category.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${story.readingTimeMinutes} min',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
