import 'package:flutter/material.dart';
import 'package:fitx/constants.dart';

/// Circular action button used across screens (AppBar actions, date selectors, etc.)
class FitXCircleBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final Color? bgColor;

  const FitXCircleBtn({
    super.key,
    required this.icon,
    this.filled = false,
    this.onTap,
    this.size = 44,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? (filled ? primaryColor : surfaceColor),
        borderRadius: BorderRadius.circular(radiusSm),
        border: filled ? null : Border.all(color: surfaceBorder),
      ),
      child: Icon(
        icon,
        color: iconColor ?? (filled ? const Color(0xFF1A1A00) : textSecondary),
        size: 20,
      ),
    );
    return onTap != null
        ? GestureDetector(onTap: onTap, child: child)
        : child;
  }
}

/// Small icon button used in app bars and toolbars
class FitXIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const FitXIconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: surfaceBorder),
        ),
        child: Icon(icon, color: textSecondary, size: 20),
      ),
    );
  }
}

/// Circular icon container with colored background
class FitXIconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double iconSize;
  final double padding;

  const FitXIconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.iconSize = 20,
    this.padding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

/// Circular avatar placeholder
class FitXAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final IconData icon;

  const FitXAvatar({
    super.key,
    this.onTap,
    this.size = 44,
    this.icon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
          color: surfaceColor,
        ),
        child: Icon(icon, color: textSecondary, size: size * 0.5),
      ),
    );
  }
}
