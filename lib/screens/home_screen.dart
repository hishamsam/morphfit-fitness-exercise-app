import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../models/exercise_session.dart';
import '../widgets/privacy_hud.dart';
import '../widgets/kinetic_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return Scaffold(
      body: Column(
        children: [
          const PrivacyHUD(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      _buildHeroSection(context, state),
                      const SizedBox(height: 48),
                      _buildBigSixHeader(context),
                      const SizedBox(height: 24),
                      _buildBentoGrid(context, state),
                      const SizedBox(height: 48),
                      _buildZeroCloudSection(context),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      toolbarHeight: 72,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCUSl7Mai5pQqXWx8V7ySuSQjt3QB5JwOVUmInMNTLK1a5o9d0hIJz7SrDZCHT3GCunhYTembiFFJ7WpggC5BuuD8qOozxLeexE7b4_HrnXvZdhwPqqxDYG8JmfgZlyycPPJUEUWijaAt7QkZt_7GzI7K4rqwlKJtZBCIaK18HG1DbYECL5z4CAU4lsJ45VSA13q8dD9fqYE2C_GLL175B69i3e2aoBJHmNNlw8SojMDjsPbZhLfPJIWmfVydsUgsXRB9D1bBOcPUz0',
              placeholder: (context, url) =>
                  Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (context, url, error) => const Icon(Icons.person),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        'MORPHFIT',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
          letterSpacing: 3.0,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.security, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, AppState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final heroFontSize = (screenWidth * 0.14).clamp(34.0, 60.0);
    final progress = state.getDailyProgress();
    final progressPct = (progress * 100).round();
    final totalVol = state.getTotalVolume();
    final volDisplay = totalVol >= 1000
        ? '${(totalVol / 1000).toStringAsFixed(1)}K'
        : totalVol.toString();
    final profile = state.profile;
    final greeting = profile != null ? 'Hi, ${profile.name}' : 'PEAK EVOLUTION';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMiniTag(context, 'DAY ${profile.daysSinceStart + 1}', AppColors.primary),
              _buildMiniTag(context, 'BMI ${profile.bmi.toStringAsFixed(1)}', AppColors.secondary),
              _buildMiniTag(context, profile.fitnessLevel.toUpperCase(), AppColors.tertiary),
            ],
          ),
        if (profile != null) const SizedBox(height: 12),
        Text(
          'CURRENT PROTOCOL',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 4.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${greeting.split(' ').first}\n',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: heroFontSize,
                      height: 0.95,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.primary],
                  ).createShader(bounds),
                  child: Text(
                    greeting.contains(' ') ? greeting.split(' ').sublist(1).join(' ') : '',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: heroFontSize,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY PROGRESS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 2.0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$progressPct',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL VOLUME',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 2.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$volDisplay REP',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.01, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: AppColors.kineticGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.todaySessionCount()} of ${bigSixExercises.length} exercises done today',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                  ),
                  Text(
                    '${state.allSessions.length} sessions total',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildBigSixHeader(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Text(
          'The Big 6',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '6 EXERCISES TOTAL',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, AppState state) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 600 ? 3 : 2;
    final cardWidth = (width - 48 - (crossCount - 1) * 16) / crossCount;
    final cardHeight = cardWidth * 1.35;
    final aspectRatio = cardWidth / cardHeight;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: bigSixExercises.map((exercise) {
        final pr = state.getPersonalRecord(exercise.name);
        final prDisplay = pr == 0 ? '—' : pr.toString();
        final isFirst = exercise.name == bigSixExercises.first.name;
        return _buildExerciseCard(
          context,
          exercise: exercise,
          prDisplay: prDisplay,
          isActive: isFirst,
          onTap: () => Navigator.pushNamed(
            context,
            '/tracker',
            arguments: {'exercise': exercise.name, 'type': exercise.type},
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required ExerciseDef exercise,
    required String prDisplay,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final isTimeBased = exercise.type == 'SEC';
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: isActive
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTimeBased ? Icons.timer : Icons.fitness_center,
                        color: isActive
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                        size: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTimeBased
                            ? AppColors.secondary.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exercise.type,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isTimeBased
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSONAL BEST',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant.withOpacity(0.5),
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            prDisplay,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (prDisplay != '—') ...[
                          const SizedBox(width: 4),
                          Text(
                            isTimeBased ? 'sec' : 'rep',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isTimeBased
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZeroCloudSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.security_update_good,
            color: AppColors.secondary,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'Zero-Cloud Architecture',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'MorphFit operates exclusively on your device hardware. Your biometric data, workout logs, and PRs are encrypted and stored in your Local Vault.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _Badge(label: '100% Offline Capable'),
              _Badge(label: 'AES-256 Encryption'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: AppColors.surfaceVariant.withOpacity(0.15))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: NavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.7),
            indicatorColor: AppColors.primary,
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 1) Navigator.pushNamed(context, '/run');
              if (index == 2) Navigator.pushNamed(context, '/workout');
              if (index == 3) Navigator.pushNamed(context, '/progress');
              if (index == 4) Navigator.pushNamed(context, '/settings');
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon:
                    Icon(Icons.home, color: AppColors.onPrimaryFixed),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map,
                    color: AppColors.onPrimaryFixed),
                label: 'RUN',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center,
                    color: AppColors.onPrimaryFixed),
                label: 'WORKOUT',
              ),
              NavigationDestination(
                icon: Icon(Icons.leaderboard_outlined),
                selectedIcon: Icon(Icons.leaderboard,
                    color: AppColors.onPrimaryFixed),
                label: 'PROGRESS',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon:
                    Icon(Icons.settings, color: AppColors.onPrimaryFixed),
                label: 'SETTINGS',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return KineticButton(
      width: 64,
      height: 64,
      onPressed: () => Navigator.pushNamed(context, '/workout'),
      child: const Icon(Icons.add, color: AppColors.onPrimaryFixed, size: 32),
    );
  }

  Widget _buildMiniTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: color,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 14),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}
