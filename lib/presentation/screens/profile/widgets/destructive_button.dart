import 'package:flutter/material.dart';

/// A button styled for destructive/dangerous actions (unmatch, report).
/// Uses [ColorScheme.error] so it always follows the app theme.
class DestructiveButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const DestructiveButton({
    super.key,
    required this.text,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: enabled && !isLoading ? onTap : null,
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      text,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
