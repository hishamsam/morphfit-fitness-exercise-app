import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.blur = 24.0,
    this.opacity = 0.7,
    this.color = const Color(0xFF1E1F26),
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: border ?? Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
