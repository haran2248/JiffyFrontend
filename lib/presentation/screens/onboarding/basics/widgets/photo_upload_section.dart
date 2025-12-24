import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/avatar.dart';

class PhotoUploadSection extends StatelessWidget {
  final VoidCallback? onTap;

  const PhotoUploadSection({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Avatar(radius: 60),
          const SizedBox(height: 16),
          Text(
            "Add your photo to get started",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "Change Photo",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryRaspberry,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
