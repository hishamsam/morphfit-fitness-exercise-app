import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme.dart';
import '../widgets/privacy_hud.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 1.5,
              height: MediaQuery.of(context).size.width * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.surface.withOpacity(0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          
          // Asymmetric Editorial Grid Decoration
          Opacity(
            opacity: 0.03,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 12,
                childAspectRatio: 0.1,
              ),
              itemBuilder: (context, index) => Container(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.onSurface)),
                ),
              ),
            ),
          ),

          // Core Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'EVOLUTION PROTOCOL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary.withOpacity(0.4),
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    'MORPHFIT',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                          letterSpacing: -4,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 1, width: 32, color: AppColors.primary.withOpacity(0.2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'KINETIC VAULT',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryDim,
                                letterSpacing: 2.0,
                                fontSize: 18,
                              ),
                        ),
                      ),
                      Container(height: 1, width: 32, color: AppColors.primary.withOpacity(0.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Decorative Corner Element
          Positioned(
            top: 60,
            right: 40,
            child: FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 48, height: 2, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Container(width: 24, height: 2, color: AppColors.primary),
                ],
              ),
            ),
          ),

          // Decorative Bottom Left Identifier
          Positioned(
            bottom: 40,
            left: 40,
            child: FadeInLeft(
              child: Text(
                'MF-OS // v.2.4.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurface.withOpacity(0.2),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // Privacy HUD
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: PrivacyHUD(),
          ),
        ],
      ),
    );
  }
}
