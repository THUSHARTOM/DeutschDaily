import 'package:hive/hive.dart';
import '../models/user_preferences.dart';

/// Service for managing user preferences (onboarding selections).
class PreferencesService {
  static const String _boxName = 'user_preferences';
  static const String _prefsKey = 'prefs';

  late Box<UserPreferences> _box;

  /// Initialize the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<UserPreferences>(_boxName);
  }

  /// Get the current user preferences (or defaults).
  UserPreferences getPreferences() {
    return _box.get(_prefsKey) ?? UserPreferences();
  }

  /// Whether the user has completed onboarding.
  bool get isOnboardingComplete => getPreferences().onboardingComplete;

  /// Save onboarding selections.
  Future<void> saveOnboarding({
    required String level,
    required List<String> categories,
  }) async {
    final prefs = UserPreferences(
      level: level,
      categories: categories,
      onboardingComplete: true,
    );
    await _box.put(_prefsKey, prefs);
  }

  /// Update the user's German level.
  Future<void> updateLevel(String level) async {
    final prefs = getPreferences();
    prefs.level = level;
    await _box.put(_prefsKey, prefs);
  }

  /// Update preferred categories.
  Future<void> updateCategories(List<String> categories) async {
    final prefs = getPreferences();
    prefs.categories = categories;
    await _box.put(_prefsKey, prefs);
  }
}
