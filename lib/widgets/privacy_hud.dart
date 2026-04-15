import 'package:flutter/material.dart';
import '../theme.dart';

class PrivacyHUD extends StatelessWidget {
  final bool isSticky;
  const PrivacyHUD({super.key, this.isSticky = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      color: AppColors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PulseIndicator(),
          const SizedBox(width: 8),
          Text(
            'LOCAL VAULT ACTIVE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 12,
            width: 1,
            color: AppColors.outlineVariant.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Text(
            'ALL DATA STORED LOCALLY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
          ),
        ],
      ),
    );
  }
}

class PulseIndicator extends StatefulWidget {
  const PulseIndicator({super.key});

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 8 * _animation.value,
              height: 8 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.5 * (1.1 - _controller.value)),
              ),
            );
          },
        ),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary,
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
