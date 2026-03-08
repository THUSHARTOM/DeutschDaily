import 'package:flutter/material.dart';
import '../locator.dart';
import '../models/story.dart';

class QuizScreen extends StatefulWidget {
  final Story story;

  const QuizScreen({super.key, required this.story});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  String? _selectedOption;
  bool _showSummary = false;
  
  final List<_Mistake> _mistakes = [];
  late final List<String> _distractorPool;
  late final List<_Question> _questions;

  @override
  void initState() {
    super.initState();
    _initDistractors();
    _questions = _generateQuestions();
  }

  void _initDistractors() {
    final words = widget.story.text.split(RegExp(r'\s+'));
    final Set<String> pool = {};
    for (var word in words) {
      final clean = word.replaceAll(RegExp(r'[^\wäöüÄÖÜß]', caseSensitive: false), '').toLowerCase();
      if (clean.isEmpty) continue;
      final entry = Locator.dictionary.lookup(clean);
      if (entry != null) {
         pool.add(entry.english);
      }
    }
    // Fallback just in case the story is super short
    if (pool.length < 5) pool.addAll(['to run', 'car', 'beautiful', 'yesterday', 'apple', 'water']);
    _distractorPool = pool.toList();
  }

  List<_Question> _generateQuestions() {
    final questions = <_Question>[];
    for (final keyword in widget.story.keywords) {
      final entry = Locator.dictionary.lookup(keyword);
      if (entry != null) {
        questions.add(
          _Question(
            germanWord: entry.lemma,
            questionText: 'What does "${entry.lemma}" mean?',
            correctAnswer: entry.english,
            options: _generateOptions(entry.english),
          ),
        );
      }
    }

    if (questions.isEmpty) {
      questions.add(_Question(
        germanWord: "Enjoyment?",
        questionText: 'Did you enjoy the story?',
        correctAnswer: 'Yes',
        options: ['Yes', 'Of course', 'Absolutely', 'Indeed'],
      ));
    }

    return questions;
  }

  List<String> _generateOptions(String correct) {
    final pool = List<String>.from(_distractorPool);
    pool.remove(correct);
    pool.shuffle();
    final options = pool.take(3).toList();
    options.add(correct);
    options.shuffle();
    return options;
  }

  void _handleAnswer(String option) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOption = option;
      final q = _questions[_currentQuestionIndex];
      if (option == q.correctAnswer) {
        _score++;
      } else {
        _mistakes.add(_Mistake(q.germanWord, option, q.correctAnswer));
      }
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOption = null;
      });
    } else {
      // Save progress and switch to summary
      final scorePercentage = ((_score / _questions.length) * 100).round();
      await Locator.progress.completeStory(widget.story.id, scorePercentage);

      setState(() {
        _showSummary = true;
      });
    }
  }

  void _finishQuiz() {
    if (mounted) {
      Navigator.pop(context); // Go back
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_showSummary) {
      return _buildSummaryScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildSummaryScreen() {
    final percentage = ((_score / _questions.length) * 100).round();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _finishQuiz,
          tooltip: 'Back to Level Selection',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Score: $_score / ${_questions.length}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'You scored $percentage%',
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            if (_mistakes.isNotEmpty) ...[
              const Text(
                'Mistakes to Review:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _mistakes.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final mistake = _mistakes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(mistake.germanWord, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('You answered: ${mistake.userAnswer}', style: const TextStyle(color: Colors.red)),
                          Text('Correct answer: ${mistake.correctAnswer}', style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Perfect score! Great job!',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _finishQuiz,
              child: const Text('Back to Level Selection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time!'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _finishQuiz,
          tooltip: 'Back to Level Selection',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 32),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ...question.options.map((opt) {
              final isCorrect = opt == question.correctAnswer;
              final isSelected = opt == _selectedOption;
              
              Color? btnColor;
              if (_answered) {
                if (isCorrect) {
                  btnColor = Colors.green;
                } else if (isSelected) {
                  btnColor = Colors.red;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: btnColor,
                    foregroundColor: _answered && (isCorrect || isSelected) ? Colors.white : null,
                  ),
                  onPressed: () => _handleAnswer(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              FilledButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'View Results',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String germanWord;
  final String questionText;
  final String correctAnswer;
  final List<String> options;

  _Question({
    required this.germanWord,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
  });
}

class _Mistake {
  final String germanWord;
  final String userAnswer;
  final String correctAnswer;

  _Mistake(this.germanWord, this.userAnswer, this.correctAnswer);
}
