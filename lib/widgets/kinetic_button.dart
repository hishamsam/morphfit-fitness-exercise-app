import 'package:flutter/material.dart';
import '../theme.dart';

class KineticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double? width;
  final double height;

  const KineticButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isPrimary = true,
    this.width,
    this.height = 64,
  });

  @override
  State<KineticButton> createState() => _KineticButtonState();
}

class _KineticButtonState extends State<KineticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isPrimary ? AppColors.kineticGradient : null,
            color: widget.isPrimary ? null : AppColors.surfaceContainerHigh,
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
