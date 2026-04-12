import 'package:flutter/material.dart';
import 'package:fitx/constants.dart';

/// Premium shimmer loading placeholder.
class FitXShimmer extends StatefulWidget {
  const FitXShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  State<FitXShimmer> createState() => _FitXShimmerState();
}

class _FitXShimmerState extends State<FitXShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(widget.borderRadius ?? radiusMd),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: const [
                surfaceColor,
                surfaceColorLight,
                surfaceColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer placeholder for an entire card.
class FitXShimmerCard extends StatelessWidget {
  const FitXShimmerCard({
    super.key,
    required this.height,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return FitXShimmer(
      width: width ?? double.infinity,
      height: height,
      borderRadius: radiusLg,
    );
  }
}
