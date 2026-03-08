import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'locator.dart';
import 'models/user_progress.dart';
import 'models/user_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(UserProgressAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());

  // Initialize Locator Services
  await Locator.init();

  runApp(const DeutschDailyApp());
}

class DeutschDailyApp extends StatelessWidget {
  const DeutschDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user has completed onboarding
    final isOnboardingComplete = Locator.preferences.isOnboardingComplete;

    return MaterialApp(
      title: 'DeutschDaily',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Supports both light/dark depending on user OS
      home: isOnboardingComplete ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
