import "package:flutter/material.dart";
import "package:jiffy/presentation/widgets/button.dart";

/// Finalize profile button widget for the curated profile screen.
///
/// A gradient primary CTA button that triggers profile finalization.
/// Designed to be used as a sticky bottom button.
class FinalizeProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const FinalizeProfileButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Button(
          text: "Looks Good, Finalize Profile",
          onTap: onTap,
          type: ButtonType.primary,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
