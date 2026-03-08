/// Model representing a German reading story.
class Story {
  final String id;
  final String title;
  final String level; // A1, A2, B1, B2
  final String category; // food, travel, daily_life, etc.
  final String text;
  final List<String> keywords;
  final List<String> translatedSentences;

  Story({
    required this.id,
    required this.title,
    required this.level,
    required this.category,
    required this.text,
    required this.keywords,
    List<String>? translatedSentences,
  }) : translatedSentences = translatedSentences ?? [];

  /// Estimated reading time in minutes (based on ~100 words/min for learners).
  int get readingTimeMinutes {
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 100).ceil().clamp(1, 10);
  }

  /// Create a Story from a JSON map.
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      text: json['text'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      translatedSentences: json['translatedSentences'] != null 
          ? List<String>.from(json['translatedSentences'] as List)
          : [],
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'category': category,
      'text': text,
      'keywords': keywords,
      'translatedSentences': translatedSentences,
    };
  }
}
