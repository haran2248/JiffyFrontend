import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

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
    return Animate(
      target: isLoading ? 0 : 1,
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap();
              },
        child: Container(
          height: 56,
          decoration: _getDecoration(context),
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
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: _getTextColor(context), size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _getTextColor(context),
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
          ),
        ).animate().shimmer(duration: 2000.ms, color: Colors.white10),
      ),
    );
  }

  BoxDecoration _getDecoration(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
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
            color: AppColors.primaryViolet,
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
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Theme.of(context).colorScheme.primary;
      case ButtonType.ghost:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }
}
