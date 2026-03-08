import 'package:flutter/material.dart';
import '../locator.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  
  String _selectedLevel = 'A1';
  final Set<String> _selectedCategories = {};
  
  final List<String> _categories = [
    'food', 'travel', 'daily_life', 'culture', 'technology', 'history', 'philosophy'
  ];

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    await Locator.preferences.saveOnboarding(
      level: _selectedLevel,
      categories: _selectedCategories.toList(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLevelSelection(),
            _buildCategorySelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Willkommen!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What is your current German level?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ...['A1', 'A2', 'B1', 'B2'].map((level) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => setState(() => _selectedLevel = level),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLevel == level
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: _selectedLevel == level
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedLevel == level)
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _nextPage,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Interests',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What topics do you want to read about?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _categories.map((cat) {
              final isSelected = _selectedCategories.contains(cat);
              return FilterChip(
                label: Text(cat.replaceAll('_', ' ').toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(cat);
                    } else {
                      _selectedCategories.remove(cat);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Start Reading'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
