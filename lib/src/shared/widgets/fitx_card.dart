import 'package:flutter/material.dart';
import 'package:fitx/constants.dart';

/// Premium glassmorphic card matching the reference design.
///
/// Features:
/// - Subtle frosted glass effect with backdrop blur
/// - Gradient border shimmer
/// - Optional accent glow for highlighted cards
/// - Smooth entry animation
class FitXCard extends StatelessWidget {
  const FitXCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.accentGlow = false,
    this.borderRadius,
    this.onTap,
    this.color,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool accentGlow;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? radiusLg;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: accentGlow ? primaryColor.withAlpha(77) : surfaceBorder,
          width: 1,
        ),
        gradient: gradient,
        boxShadow: accentGlow
            ? [
                BoxShadow(
                  color: primaryColor.withAlpha(20),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(spaceMd),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// A subtle glassmorphic card with lighter surface.
class FitXCardElevated extends StatelessWidget {
  const FitXCardElevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return FitXCard(
      color: surfaceColorLight,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
