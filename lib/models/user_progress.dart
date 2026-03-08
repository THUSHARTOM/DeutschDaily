import 'package:hive/hive.dart';

part 'user_progress.g.dart';

/// Tracks the user's progress on a single story.
@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  final String storyId;

  @HiveField(1)
  bool completed;

  @HiveField(2)
  int quizScore;

  @HiveField(3)
  List<String> keywordsLearned;

  @HiveField(4)
  DateTime? lastReadAt;

  UserProgress({
    required this.storyId,
    this.completed = false,
    this.quizScore = 0,
    List<String>? keywordsLearned,
    this.lastReadAt,
  }) : keywordsLearned = keywordsLearned ?? [];
}
