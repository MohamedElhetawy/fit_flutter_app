import 'package:flutter/material.dart';

/// Smooth animated counter that interpolates between values.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.fractionDigits = 1,
    this.suffix = '',
    this.prefix = '',
  });

  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int fractionDigits;
  final String suffix;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix${animatedValue.toStringAsFixed(fractionDigits)}$suffix',
          style: style ?? Theme.of(context).textTheme.displayMedium,
        );
      },
    );
  }
}

/// Integer version of animated counter.
class AnimatedIntCounter extends StatelessWidget {
  const AnimatedIntCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.suffix = '',
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.round()}$suffix',
          style: style ?? Theme.of(context).textTheme.displayMedium,
        );
      },
    );
  }
}
