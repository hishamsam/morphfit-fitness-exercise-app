import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'state_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/ghost_camera_screen.dart';
import 'screens/progress_mirror_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/exercise_tracker_screen.dart';
import 'screens/run_screen.dart';
import 'screens/run_summary_screen.dart';
import 'models/run_session.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final appState = AppState();
    appState.init(); // Fire and forget in startup path
    runApp(AppStateProvider(
      state: appState,
      child: const MorphFitApp(),
    ));
  } catch (e, stack) {
    debugPrint('CRITICAL STARTUP ERROR: $e\n$stack');
    // Minimal fallback app if everything fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Startup Error: $e')),
      ),
    ));
  }
}

class MorphFitApp extends StatelessWidget {
  const MorphFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MorphFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenWrapper(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/camera': (context) => const GhostCameraScreen(),
        '/progress': (context) => const ProgressMirrorScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/run': (context) => const RunScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tracker') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (_) => ExerciseTrackerScreen(
              exercise: args?['exercise'] ?? 'Push-ups',
              type: args?['type'] ?? 'REP',
            ),
          );
        }
        if (settings.name == '/run_summary') {
          final session = settings.arguments as RunSession;
          return MaterialPageRoute(
            builder: (_) => RunSummaryScreen(session: session),
          );
        }
        return null;
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _navigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_navigating) {
      _navigating = true;
      _handleSplash();
    }
  }

  Future<void> _handleSplash() async {
    // Always show splash for at least 1.8 seconds
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Wait for state init, but never more than 3 extra seconds
    final state = AppStateProvider.of(context);
    if (!state.isInitialized) {
      await state.initializationDone
          .timeout(const Duration(seconds: 3), onTimeout: () {})
          .catchError((_) {});
    }

    if (!mounted) return;
    final destination = state.hasProfile ? '/home' : '/onboarding';
    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
