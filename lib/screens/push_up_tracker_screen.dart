import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../widgets/privacy_hud.dart';
import '../widgets/kinetic_button.dart';

class PushUpTrackerScreen extends StatelessWidget {
  const PushUpTrackerScreen({super.key});

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
                  _buildTopNav(context),
                  const SizedBox(height: 16),
                  _buildHeaderInfo(context),
                  const SizedBox(height: 32),
                  _buildMetricsBento(context),
                  const SizedBox(height: 32),
                  _buildInstructionCard(context),
                  const SizedBox(height: 48),
                  _buildActionModule(context),
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

  Widget _buildTopNav(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuARu-xaiyApMMjsqb62SPgpu5ERLonzVoS5qmEbS_uYH6rEAZ8n3LI0rVheoLm6bv967WM_m3JM7ld-y51huO6kzcC62Do8nX6oV08mgaCtGWJQqCl5EzW-ycSYSfqZ6WD0Cg0HLTfaaAYDWgFTVBkyYbrzCy9sQLRdPH3wwyA3GRvMaibBJxWC8WWQzLXl-MvIgIiLNPnKl-phI8CXu_S02fTHBvnveeHLjpvZvV-t0ENVa82R1_DU-mEt5pi2G0PfqcEC6f93e4Sq',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'MORPHFIT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.security, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SESSION: PUSH-UP ALPHA',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'VOLT KINETIC',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
        ),
      ],
    );
  }

  Widget _buildMetricsBento(BuildContext context) {
    return Column(
      children: [
        // Large Rep Counter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: -20,
                right: -20,
                child: Text(
                  'REPS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'TOTAL COUNT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary.withOpacity(0.5),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '32',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -6.0,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Container(
                              width: 3,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: index < 3 ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'INTENSITY: HIGH',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 9,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Secondary Metrics Row
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                context,
                'BURNED (KCAL)',
                '148',
                'CAL',
                borderColor: AppColors.primary.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricBox(
                context,
                'ELAPSED',
                '12:44',
                'MIN',
                borderColor: AppColors.secondary.withOpacity(0.2),
                valueColor: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBox(
    BuildContext context,
    String label,
    String value,
    String unit, {
    Color? borderColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(color: borderColor ?? Colors.transparent, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 8,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: (valueColor ?? AppColors.primary).withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: AppColors.primaryDim, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                children: const [
                  TextSpan(text: 'Maintain a '),
                  TextSpan(text: 'plank position', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  TextSpan(text: '. Focus on the eccentric phase of the movement. Your vault is currently syncing 128-bit encrypted training data to local storage.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionModule(BuildContext context) {
    return Column(
      children: [
        KineticButton(
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pause, color: AppColors.onPrimaryFixed, size: 28),
              const SizedBox(width: 12),
              Text(
                'PAUSE TRAINING',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 2.0,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.errorContainer.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stop_circle, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Text(
                  'END SESSION',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.15))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: NavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.7),
            indicatorColor: AppColors.primary,
            selectedIndex: 1,
            onDestinationSelected: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 2) Navigator.pushReplacementNamed(context, '/progress');
              if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'HOME'),
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                selectedIcon: Icon(Icons.fitness_center, color: AppColors.onPrimaryFixed),
                label: 'WORKOUT',
              ),
              NavigationDestination(icon: Icon(Icons.leaderboard_outlined), label: 'PROGRESS'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }
}
