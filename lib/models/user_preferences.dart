import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

/// Stores the user's onboarding selections and app preferences.
@HiveType(typeId: 1)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String level; // A1, A2, B1, B2

  @HiveField(1)
  List<String> categories; // food, travel, daily_life, etc.

  @HiveField(2)
  bool onboardingComplete;

  UserPreferences({
    this.level = 'A1',
    List<String>? categories,
    this.onboardingComplete = false,
  }) : categories = categories ?? [];
}
