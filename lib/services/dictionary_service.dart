import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dictionary_entry.dart';

/// Service for fast German → English word lookup.
///
/// Loads the dictionary JSON into an in-memory HashMap at startup for O(1) lookups.
/// Handles normalization: lowercasing and punctuation stripping.
class DictionaryService {
  /// In-memory dictionary: lowercase word form → DictionaryEntry.
  final Map<String, DictionaryEntry> _dictionary = {};

  bool _loaded = false;

  /// Whether the dictionary has been loaded.
  bool get isLoaded => _loaded;

  /// Number of word forms in the dictionary.
  int get wordCount => _dictionary.length;

  /// Load the dictionary from the bundled JSON asset.
  Future<void> load() async {
    if (_loaded) return;

    final jsonString =
        await rootBundle.loadString('assets/dictionary/dictionary.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    for (final entry in data.entries) {
      _dictionary[entry.key.toLowerCase()] =
          DictionaryEntry.fromJson(entry.value as Map<String, dynamic>);
    }

    _loaded = true;
  }

  /// Look up a word, handling normalization (lowercase, strip punctuation).
  ///
  /// Returns null if the word is not found.
  DictionaryEntry? lookup(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) return null;
    return _dictionary[normalized];
  }

  /// Normalize a word: lowercase and strip leading/trailing punctuation.
  String _normalize(String word) {
    // Remove leading/trailing punctuation and whitespace
    String cleaned = word.replaceAll(RegExp(r'^[^\p{L}]+|[^\p{L}]+$', unicode: true), '');
    return cleaned.toLowerCase();
  }
}
