import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonType { primary, secondary, ghost }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;

  const Button({
    super.key,
    required this.text,
    required this.onTap,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = _getDecoration(context);
    final textColor = _getTextColor(context);
    
    Widget buttonContent = Container(
      height: 56,
      constraints: const BoxConstraints(minWidth: 120),
      decoration: decoration,
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );

    if (!isLoading) {
      buttonContent = buttonContent.animate().shimmer(
        duration: 2000.ms,
        color: Colors.white10,
      );
    }

    if (isLoading) {
      return Animate(
        target: 0,
        child: buttonContent,
      );
    }

    return Animate(
      target: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Haptic feedback is only available on mobile platforms
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
              HapticFeedback.lightImpact();
            }
            onTap();
          },
          borderRadius: BorderRadius.circular(30),
          splashColor: type == ButtonType.primary
              ? Colors.white.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: type == ButtonType.primary
              ? Colors.white.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          child: buttonContent,
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryViolet.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        );
      case ButtonType.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        );
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case ButtonType.primary:
        // Use onPrimary for primary buttons to ensure contrast
        return colorScheme.onPrimary;
      case ButtonType.secondary:
        return colorScheme.primary;
      case ButtonType.ghost:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }
}
