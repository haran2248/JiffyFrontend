import 'package:flutter/material.dart';

/// Rounded icon card used in verification screens.
///
/// Displays an icon inside a rounded rectangle with customizable
/// background color/gradient and icon color.
class VerificationIconCard extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Gradient? gradient;
  final double size;
  final double iconSize;
  final double borderRadius;

  const VerificationIconCard({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.gradient,
    this.size = 72,
    this.iconSize = 32,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            gradient == null ? (backgroundColor ?? colorScheme.primary) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? colorScheme.onPrimary,
        ),
      ),
    );
  }
}
