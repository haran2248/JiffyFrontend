import 'package:flutter/material.dart';

/// A badge widget to display verification status.
///
/// Shows a green checkmark badge when verified.
class ProfileVerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;

  const ProfileVerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size - 4,
      ),
    );
  }
}
