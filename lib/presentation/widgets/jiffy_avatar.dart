import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class JiffyAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;

  const JiffyAvatar({
    super.key,
    this.radius = 48,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfacePlum,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? Icon(
                Icons.camera_alt_outlined,
                size: radius * 0.8,
                color: AppColors.textSecondary,
              )
            : null,
      ),
    );
  }
}
