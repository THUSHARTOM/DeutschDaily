import 'package:flutter/material.dart';
import '../locator.dart';
import '../models/story.dart';
import '../widgets/story_card.dart';
import 'story_reader_screen.dart';

class StoryBrowserScreen extends StatefulWidget {
  const StoryBrowserScreen({super.key});

  @override
  State<StoryBrowserScreen> createState() => _StoryBrowserScreenState();
}

class _StoryBrowserScreenState extends State<StoryBrowserScreen> {
  String _selectedLevel = 'All';
  String _selectedCategory = 'All';
  String _statusFilter = 'All'; // All, Unread, Completed

  final List<String> _levels = ['All', 'A1', 'A2', 'B1', 'B2'];
  final List<String> _categories = [
    'All', 'food', 'travel', 'daily_life', 'culture', 'technology', 'history', 'philosophy'
  ];
  final List<String> _statuses = ['All', 'Unread', 'Completed'];

  void _navigateToStory(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryReaderScreen(story: story),
      ),
    ).then((_) => setState(() {})); // Refresh status bubbles
  }

  @override
  Widget build(BuildContext context) {
    final completedIds = Locator.progress.getCompletedIds();
    
    final filteredStories = Locator.story.filter(
      level: _selectedLevel == 'All' ? null : _selectedLevel,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      completedIds: completedIds,
      showCompleted: _statusFilter == 'All' ? null : (_statusFilter == 'Completed'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildDropdown(_selectedLevel, _levels, (val) => setState(() => _selectedLevel = val!)),
                const SizedBox(width: 8),
                _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!), isCategory: true),
                const SizedBox(width: 8),
                _buildDropdown(_statusFilter, _statuses, (val) => setState(() => _statusFilter = val!)),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: filteredStories.isEmpty
                ? const Center(child: Text('No stories found.'))
                : ListView.builder(
                    itemCount: filteredStories.length,
                    itemBuilder: (context, index) {
                      final story = filteredStories[index];
                      return StoryCard(
                        story: story,
                        isCompleted: completedIds.contains(story.id),
                        onTap: () => _navigateToStory(story),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged, {bool isCategory = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: items.map((item) {
            final display = isCategory && item != 'All' ? item.replaceAll('_', ' ').toUpperCase() : item;
            return DropdownMenuItem(
              value: item,
              child: Text(display, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
