import 'package:flutter/material.dart';
import '../locator.dart';
import '../widgets/streak_display.dart';
import '../widgets/story_card.dart';
import '../models/story.dart';
import 'story_browser_screen.dart';
import 'story_reader_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  Story? _continueStory;
  List<Story> _recommendedStories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final streak = await Locator.streak.recordLogin();
    
    final prefs = Locator.preferences.getPreferences();
    final completedIds = Locator.progress.getCompletedIds();

    final lastReadId = Locator.progress.getLastReadIncompleteId();
    Story? continueStory;
    if (lastReadId != null) {
      continueStory = Locator.story.getById(lastReadId);
    }

    final recommended = Locator.story.getRecommended(
      level: prefs.level,
      completedIds: completedIds,
    );

    setState(() {
      _streak = streak;
      _continueStory = continueStory;
      _recommendedStories = recommended;
    });
  }

  void _navigateToStory(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryReaderScreen(story: story),
      ),
    ).then((_) => _loadData()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app_icon.png', height: 40),
            const SizedBox(width: 8),
            const Text('DeutschDaily', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps), // Main menu/library icon
            tooltip: 'Level Selection',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryBrowserScreen()),
              ).then((_) => _loadData());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: StreakDisplay(streak: _streak)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_continueStory != null) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Continue Reading',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              StoryCard(
                story: _continueStory!,
                onTap: () => _navigateToStory(_continueStory!),
              ),
            ],
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended For You',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoryBrowserScreen()),
                      ).then((_) => _loadData());
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            
            if (_recommendedStories.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text("You've read everything at your level!")))
            else
              ..._recommendedStories.map((story) => StoryCard(
                    story: story,
                    onTap: () => _navigateToStory(story),
                  )),
                  
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackScreen()),
          );
        },
        tooltip: 'Feedback',
        child: const Icon(Icons.favorite),
      ),
    );
  }
}
