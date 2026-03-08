import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../locator.dart';
import '../models/story.dart';
import '../models/dictionary_entry.dart';
import '../widgets/word_popup.dart';
import '../widgets/keyword_chip.dart';
import 'quiz_screen.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  DictionaryEntry? _activePopup;
  String? _activeSentenceTranslation;
  List<String> _learnedKeywords = [];
  
  // Highlighting state
  int? _selectedWordIndex;
  int? _selectedSentenceIndex;
  
  // Reading Mode
  bool _isSentenceMode = false;

  late final List<String> _tokens;
  late final List<String> _sentences;

  @override
  void initState() {
    super.initState();
    Locator.progress.startStory(widget.story.id);
    _loadProgress();
    
    // Split into words while preserving spaces/punctuation attached to words
    _tokens = widget.story.text.split(RegExp(r'(?<=\s)'));
    
    // Simple sentence splitter (splitting on . ! ? followed by space)
    _sentences = widget.story.text.split(RegExp(r'(?<=[.!?])\s+'));
  }

  void _loadProgress() {
    final progress = Locator.progress.getProgress(widget.story.id);
    if (progress != null) {
      setState(() {
        _learnedKeywords = progress.keywordsLearned;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedWordIndex = null;
      _selectedSentenceIndex = null;
      _activePopup = null;
      _activeSentenceTranslation = null;
    });
  }

  void _handleWordTap(String rawWord, int index) {
    if (rawWord.trim().isEmpty) return;

    final entry = Locator.dictionary.lookup(rawWord);
    
    setState(() {
      _selectedWordIndex = index;
      _activePopup = entry;
    });

    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${rawWord.trim()}" not found.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleSentenceTap(int sentenceIndex) {
    setState(() {
      _selectedSentenceIndex = sentenceIndex;
      if (sentenceIndex < widget.story.translatedSentences.length) {
        _activeSentenceTranslation = widget.story.translatedSentences[sentenceIndex];
      } else {
        _activeSentenceTranslation = "Translation not available.";
      }
    });
  }

  void _toggleKeyword(String keyword, bool isLearned) async {
    if (isLearned) {
      await Locator.progress.learnKeyword(widget.story.id, keyword);
    } else {
      await Locator.progress.unlearnKeyword(widget.story.id, keyword);
    }
    _loadProgress();
  }

  void _finishReading() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(story: widget.story),
      ),
    );
  }

  /// Tokenizes the text into clickable words (Word Mode).
  List<InlineSpan> _buildWordSpans() {
    final spans = <InlineSpan>[];
    for (var i = 0; i < _tokens.length; i++) {
        final token = _tokens[i];
        final isSelected = i == _selectedWordIndex;
        
        // Strip trailing space to ensure highlight doesn't cover empty space
        final word = token.trimRight();
        final trailingSpace = token.substring(word.length);

        spans.add(
            TextSpan(
                text: word,
                style: TextStyle(
                    fontSize: 22,
                    height: 1.8,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
                        : Colors.transparent,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => _handleWordTap(word, i),
            ),
        );
        
        if (trailingSpace.isNotEmpty) {
             spans.add(
                 TextSpan(
                     text: trailingSpace,
                     style: TextStyle(
                         fontSize: 22,
                         height: 1.8,
                         color: Theme.of(context).textTheme.bodyLarge?.color,
                     ),
                 ),
             );
        }
    }
    return spans;
  }

  /// Tokenizes the text into clickable sentences (Sentence Mode).
  List<InlineSpan> _buildSentenceSpans() {
    final spans = <InlineSpan>[];
    for (var i = 0; i < _sentences.length; i++) {
        final sentence = _sentences[i];
        final isSelected = i == _selectedSentenceIndex;

        spans.add(
            TextSpan(
                text: '$sentence ',
                style: TextStyle(
                    fontSize: 22,
                    height: 1.8,
                    color: isSelected ? Theme.of(context).colorScheme.tertiary : Theme.of(context).textTheme.bodyLarge?.color,
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2) 
                        : Colors.transparent,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => _handleSentenceTap(i),
            ),
        );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearSelection, // Tapping outside clears highlight
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.story.title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  widget.story.level,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Story Title Heading
                  Text(
                    widget.story.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Word Mode', style: TextStyle(fontSize: 12)),
                      Switch(
                        value: _isSentenceMode,
                        onChanged: (val) {
                          setState(() {
                            _isSentenceMode = val;
                            _clearSelection();
                          });
                        },
                      ),
                      const Text('Sentence Mode', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Text Area
                  RichText(
                    text: TextSpan(
                      children: _isSentenceMode ? _buildSentenceSpans() : _buildWordSpans(),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Key Words in This Story',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.story.keywords.map((kw) {
                      return KeywordChip(
                        keyword: kw,
                        isLearned: _learnedKeywords.contains(kw),
                        onToggle: (val) => _toggleKeyword(kw, val),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _finishReading,
                      child: const Text('Finish Reading & Take Quiz'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Popups overlay
            if (!_isSentenceMode && _activePopup != null)
              WordPopup(
                entry: _activePopup!,
                onClose: _clearSelection,
              ),
              
            if (_isSentenceMode && _activeSentenceTranslation != null)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Sentence Translation',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearSelection,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _activeSentenceTranslation!,
                            style: const TextStyle(fontSize: 18, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
