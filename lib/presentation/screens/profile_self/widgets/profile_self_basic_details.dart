import 'package:flutter/material.dart';
import 'package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart';
import 'package:jiffy/presentation/screens/profile_self/widgets/profile_self_section_card.dart';

/// Basic details section widget for profile self screen.
///
/// Displays height, job, education, lifestyle, and relationship goals.
class ProfileSelfBasicDetails extends StatelessWidget {
  final ProfileSelfData data;
  final VoidCallback? onEdit;

  const ProfileSelfBasicDetails({
    super.key,
    required this.data,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> details = [];

    // Professional & Education
    if (data.jobTitle != null && data.jobTitle!.isNotEmpty) {
      String workText = data.jobTitle!;
      if (data.company != null && data.company!.isNotEmpty) {
        workText += " at ${data.company}";
      }
      details.add(_buildDetailChip(context, Icons.work_outline, workText));
    } else if (data.company != null && data.company!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.work_outline, data.company!));
    }

    if (data.college != null && data.college!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.school_outlined, data.college!));
    }

    // Physical & Lifestyle
    if (data.height != null && data.height!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.height, data.height!));
    }

    if (data.drinking != null && data.drinking!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.local_bar_outlined, data.drinking!));
    }

    if (data.smoking != null && data.smoking!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.smoking_rooms_outlined, data.smoking!));
    }

    if (data.diet != null && data.diet!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.restaurant_outlined, data.diet!));
    }

    // Preferences
    if (data.relationshipGoals != null && data.relationshipGoals!.isNotEmpty) {
      details.add(_buildDetailChip(context, Icons.favorite_border, data.relationshipGoals!));
    }

    return ProfileSelfSectionCard(
      title: "Basic Details",
      onEdit: onEdit,
      child: details.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  "No basic details added yet",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details,
            ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
