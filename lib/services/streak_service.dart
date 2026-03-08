import 'package:hive/hive.dart';

/// Service for tracking daily login streaks.
///
/// Records each day the user opens the app. If the user skips a day,
/// the streak resets to 1. The streak is stored as a list of date strings.
class StreakService {
  static const String _boxName = 'streak_data';
  static const String _streakKey = 'current_streak';
  static const String _lastDateKey = 'last_login_date';

  late Box<dynamic> _box;

  /// Initialize the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Record today's login and return the updated streak count.
  Future<int> recordLogin() async {
    final today = _todayString();
    final lastDate = _box.get(_lastDateKey) as String?;

    if (lastDate == today) {
      // Already logged in today
      return currentStreak;
    }

    final yesterday = _dateString(DateTime.now().subtract(const Duration(days: 1)));

    int streak;
    if (lastDate == yesterday) {
      // Consecutive day — increment streak
      streak = ((_box.get(_streakKey) as int?) ?? 0) + 1;
    } else {
      // Missed at least one day — reset streak
      streak = 1;
    }

    await _box.put(_streakKey, streak);
    await _box.put(_lastDateKey, today);

    return streak;
  }

  /// Get the current streak count.
  int get currentStreak => (_box.get(_streakKey) as int?) ?? 0;

  /// Get the last login date.
  String? get lastLoginDate => _box.get(_lastDateKey) as String?;

  /// Format today's date as YYYY-MM-DD.
  String _todayString() => _dateString(DateTime.now());

  /// Format a date as YYYY-MM-DD.
  String _dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
