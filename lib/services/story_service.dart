import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/story.dart';

/// Service for loading and filtering stories from bundled JSON assets.
class StoryService {
  final List<Story> _stories = [];

  bool _loaded = false;

  /// Whether stories have been loaded.
  bool get isLoaded => _loaded;

  /// All loaded stories.
  List<Story> get allStories => List.unmodifiable(_stories);

  /// Load all story JSON files from assets.
  Future<void> load() async {
    if (_loaded) return;

    try {
      final jsonString = await rootBundle
          .loadString('assets/stories/german_learning_stories_A1_B2_translated.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data.containsKey('stories')) {
        final storyList = data['stories'] as List;
        for (final item in storyList) {
          _stories.add(Story.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading stories: $e');
    }

    _loaded = true;
  }

  /// Get stories filtered by level.
  List<Story> getByLevel(String level) {
    return _stories.where((s) => s.level == level).toList();
  }

  /// Get stories filtered by category.
  List<Story> getByCategory(String category) {
    return _stories.where((s) => s.category == category).toList();
  }

  /// Filter stories by multiple criteria.
  List<Story> filter({
    String? level,
    String? category,
    Set<String>? completedIds,
    bool? showCompleted,
  }) {
    return _stories.where((story) {
      if (level != null && story.level != level) return false;
      if (category != null && story.category != category) return false;

      if (showCompleted != null && completedIds != null) {
        final isCompleted = completedIds.contains(story.id);
        if (showCompleted && !isCompleted) return false;
        if (!showCompleted && isCompleted) return false;
      }

      return true;
    }).toList();
  }

  /// Get a single story by ID.
  Story? getById(String id) {
    try {
      return _stories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get recommended stories for a user based on their level and incomplete status.
  List<Story> getRecommended({
    required String level,
    required Set<String> completedIds,
    int limit = 5,
  }) {
    final unread = _stories
        .where((s) => s.level == level && !completedIds.contains(s.id))
        .toList();
    unread.shuffle();
    return unread.take(limit).toList();
  }
}
