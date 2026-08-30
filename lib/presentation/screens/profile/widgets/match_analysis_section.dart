import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/widgets/card.dart";

class MatchAnalysisSection extends StatelessWidget {
  final ProfileData profile;

  const MatchAnalysisSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final matchPitch = profile.matchPitch;

    if (matchPitch == null) {
      return const SizedBox.shrink();
    }

    return SystemCard(
      padding: const EdgeInsets.all(16),
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Match Analysis",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (matchPitch.vibeText != null && matchPitch.vibeText!.isNotEmpty) ...[
            _buildSectionTitle(context, "The Vibe", Icons.star_border),
            const SizedBox(height: 8),
            Text(
              matchPitch.vibeText!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 24),
          ],

          _buildSectionTitle(context, "Your Trajectory", Icons.trending_up),
          const SizedBox(height: 16),
          
          Text(
            "HER JOURNEY SO FAR",
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildJourneyItem(context, Icons.location_on_outlined, profile.location ?? "Unknown Origin"),
          if (profile.college != null) _buildJourneyItem(context, Icons.school_outlined, profile.college!),
          if (profile.jobTitle != null) _buildJourneyItem(context, Icons.work_outline, profile.jobTitle!),
          
          const SizedBox(height: 16),
          Text(
            "WHAT I SEE FOR YOU TWO",
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (matchPitch.trajectoryOptions != null)
            ...matchPitch.trajectoryOptions!.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("•", style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, height: 1.2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      opt,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
            )),

          const SizedBox(height: 24),

          if (matchPitch.frictionText != null && matchPitch.frictionText!.isNotEmpty) ...[
            _buildSectionTitle(context, "The Friction", Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(height: 8),
            Text(
              matchPitch.frictionText!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 24),
          ],

          if (matchPitch.verdictText != null && matchPitch.verdictText!.isNotEmpty) ...[
            _buildSectionTitle(context, "The Jiffy Verdict", Icons.gavel, color: colorScheme.secondary),
            const SizedBox(height: 8),
            Text(
              matchPitch.verdictText!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final c = color ?? colorScheme.primary;

    return Row(
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: c,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
