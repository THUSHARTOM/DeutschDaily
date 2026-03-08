import 'package:hive/hive.dart';
import '../models/user_progress.dart';

/// Service for tracking story completion, quiz scores, and keyword learning.
class ProgressService {
  static const String _boxName = 'user_progress';

  late Box<UserProgress> _box;

  /// Initialize the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<UserProgress>(_boxName);
  }

  /// Get progress for a specific story.
  UserProgress? getProgress(String storyId) {
    return _box.get(storyId);
  }

  /// Get all progress entries.
  List<UserProgress> getAllProgress() {
    return _box.values.toList();
  }

  /// Get the set of all completed story IDs.
  Set<String> getCompletedIds() {
    return _box.values
        .where((p) => p.completed)
        .map((p) => p.storyId)
        .toSet();
  }

  /// Get the set of all started (but not necessarily completed) story IDs.
  Set<String> getStartedIds() {
    return _box.values.map((p) => p.storyId).toSet();
  }

  /// Mark a story as completed with a quiz score.
  Future<void> completeStory(String storyId, int quizScore) async {
    final existing = _box.get(storyId);
    if (existing != null) {
      existing.completed = true;
      existing.quizScore = quizScore;
      existing.lastReadAt = DateTime.now();
      await existing.save();
    } else {
      await _box.put(
        storyId,
        UserProgress(
          storyId: storyId,
          completed: true,
          quizScore: quizScore,
          lastReadAt: DateTime.now(),
        ),
      );
    }
  }

  /// Record that a story has been started (but not completed).
  Future<void> startStory(String storyId) async {
    if (_box.get(storyId) == null) {
      await _box.put(
        storyId,
        UserProgress(
          storyId: storyId,
          lastReadAt: DateTime.now(),
        ),
      );
    } else {
      final existing = _box.get(storyId)!;
      existing.lastReadAt = DateTime.now();
      await existing.save();
    }
  }

  /// Mark a keyword as learned for a story.
  Future<void> learnKeyword(String storyId, String keyword) async {
    final progress = _box.get(storyId);
    if (progress != null) {
      if (!progress.keywordsLearned.contains(keyword)) {
        progress.keywordsLearned.add(keyword);
        await progress.save();
      }
    }
  }

  /// Unmark a keyword as learned for a story.
  Future<void> unlearnKeyword(String storyId, String keyword) async {
    final progress = _box.get(storyId);
    if (progress != null) {
      progress.keywordsLearned.remove(keyword);
      await progress.save();
    }
  }

  /// Get the most recently read incomplete story ID.
  String? getLastReadIncompleteId() {
    final incomplete = _box.values
        .where((p) => !p.completed && p.lastReadAt != null)
        .toList();
    if (incomplete.isEmpty) return null;
    incomplete.sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!));
    return incomplete.first.storyId;
  }

  /// Total number of stories completed.
  int get completedCount => _box.values.where((p) => p.completed).length;

  /// Total keywords learned across all stories.
  int get totalKeywordsLearned {
    return _box.values.fold(0, (sum, p) => sum + p.keywordsLearned.length);
  }
}
