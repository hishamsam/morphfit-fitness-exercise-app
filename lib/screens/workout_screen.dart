import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/exercise_session.dart';
import '../widgets/privacy_hud.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PrivacyHUD(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildWorkoutSection(
                    context,
                    'CORE MOVEMENTS',
                    bigSixExercises.where((e) => e.type == 'REP').toList(),
                  ),
                  const SizedBox(height: 32),
                  _buildWorkoutSection(
                    context,
                    'ISOMETRIC STABILITY',
                    bigSixExercises.where((e) => e.type == 'SEC').toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT MODULE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Training Hub',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(
      BuildContext context, String title, List<ExerciseDef> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildWorkoutCard(context, item)),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, ExerciseDef item) {
    final isTimeBased = item.type == 'SEC';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            '/tracker',
            arguments: {'exercise': item.name, 'type': item.type},
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isTimeBased ? Icons.timer : Icons.fitness_center,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isTimeBased ? AppColors.secondary : AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.15))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: NavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.7),
            indicatorColor: AppColors.primary,
            selectedIndex: 2,
            onDestinationSelected: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 1) Navigator.pushReplacementNamed(context, '/run');
              if (index == 3) Navigator.pushReplacementNamed(context, '/progress');
              if (index == 4) Navigator.pushReplacementNamed(context, '/settings');
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined), label: 'HOME'),
              NavigationDestination(
                  icon: Icon(Icons.map_outlined), label: 'RUN'),
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                selectedIcon: Icon(Icons.fitness_center,
                    color: AppColors.onPrimaryFixed),
                label: 'WORKOUT',
              ),
              NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined), label: 'PROGRESS'),
              NavigationDestination(
                  icon: Icon(Icons.settings_outlined), label: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }
}
