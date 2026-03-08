import 'services/dictionary_service.dart';
import 'services/story_service.dart';
import 'services/progress_service.dart';
import 'services/streak_service.dart';
import 'services/preferences_service.dart';

/// Simple service locator pattern without external dependencies.
class Locator {
  static final DictionaryService dictionary = DictionaryService();
  static final StoryService story = StoryService();
  static final ProgressService progress = ProgressService();
  static final StreakService streak = StreakService();
  static final PreferencesService preferences = PreferencesService();

  /// Initialize all required services.
  static Future<void> init() async {
    await progress.init();
    await streak.init();
    await preferences.init();
    
    // We can load story and dictionary in background or immediately
    await story.load();
    await dictionary.load();
  }
}
