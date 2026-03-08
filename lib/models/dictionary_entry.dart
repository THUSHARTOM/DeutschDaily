/// Model representing a single dictionary entry for a German word form.
///
/// Each entry maps a word form (possibly inflected) to its base form (lemma)
/// and provides the English translation, part of speech, and an optional example.
class DictionaryEntry {
  final String lemma;
  final String english;
  final String pos; // noun, verb, adjective, adverb, etc.
  final String? example;

  DictionaryEntry({
    required this.lemma,
    required this.english,
    required this.pos,
    this.example,
  });

  /// Create from JSON map.
  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      lemma: json['lemma'] as String,
      english: json['english'] as String,
      pos: json['pos'] as String,
      example: json['example'] as String?,
    );
  }
}
