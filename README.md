# DeutschDaily

![GitHub Downloads](https://img.shields.io/github/downloads/THUSHARTOM/DeutschDaily/total)

A minimalistic, offline-first Flutter application for learning German through reading short stories. 

The app features a built-in dictionary that supports tappable word lookup, progress tracking, daily streaks, and post-reading quizzes — all without requiring an internet connection or backend server.

## Features
- **Offline-First:** All data (stories and dictionary) is bundled into the app. No internet connection needed.
- **Tappable Reader:** Every word in a story is tappable. Tapping a word reveals a floating dictionary popup showing the English meaning, part of speech, and lemma.
- **Smart Dictionary lookup:** Fully supports German word inflections (e.g., clicking *geht* maps to the base verb *gehen*).
- **Progress Tracking:** Tracks which stories you've completed, your quiz scores, and the vocabulary you've learned.
- **Daily Streak:** Motivates consistent learning with a daily login streak system.
- **Post-Reading Quizzes:** Tests comprehension and vocabulary dynamically generated from story keywords.
- **Beautiful UI:** Clean typography using Google Fonts (Inter) with full dark mode support.

## Project Architecture
- Built with **Flutter** (Dart).
- **State & Data Management:** 
  - `Hive` for fast, local NoSQL storage (saving user progress, preferences, and streaks).
  - Pre-loaded JSON files (`assets/stories/` and `assets/dictionary/`) loaded into memory at startup to ensure instant O(1) dictionary lookups.
- **Clean Structure:** Code is organized into `/models`, `/services`, `/screens`, and shared `/widgets`. Simple service locator pattern handles dependency injection.

## How to Run Locally

### Requirements
- Flutter SDK (>= 3.11.1)
- Either an Android device/emulator, iOS device/simulator, or Web/Desktop setup.

### Development
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## How to Extend Content

Because this app uses local JSON files to store content, it's very easy to expand.

### Adding New Stories
1. Navigate to `assets/stories/` and open the JSON file corresponding to the difficulty level (e.g. `stories_A1.json`).
2. Add a new JSON object to the array:
   ```json
   {
     "id": "A1_002",
     "title": "Dein Neurer Titel",
     "level": "A1",
     "category": "travel",
     "text": "Dein deutscher Text hier...",
     "keywords": ["Wort1", "Wort2"]
   }
   ```
3. Restart the app. The home screen and story browser will automatically pick up the new story.

### Expanding the Dictionary
To ensure words in the new stories can be tapped and translated:
1. Open `assets/dictionary/dictionary.json`.
2. Add the **inflected** form of the word as the key (in lowercase).
3. Map it to the dictionary base entry:
   ```json
   "gehst": {
     "lemma": "gehen",
     "english": "to go",
     "pos": "verb",
     "example": "Du gehst nach Hause."
   }
   ```
*Note: We recommend scripting big additions to the dictionary from an external CSV/database source to handle the large volumes of German inflections.*

## How to Build the APK

To build a release APK for Android devices:

```bash
flutter build apk
```
The output file will be located in `build/app/outputs/flutter-apk/app-release.apk`.
