import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

class MatchAnalysisSection extends StatelessWidget {
  final ProfileData profile;

  const MatchAnalysisSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final matchPitch = profile.matchPitch;

    // Only show if any pitch field is populated
    if (matchPitch == null) return const SizedBox.shrink();

    final hasVibe =
        matchPitch.vibeText != null && matchPitch.vibeText!.isNotEmpty;
    final hasComplement = matchPitch.complementText != null &&
        matchPitch.complementText!.isNotEmpty;
    final hasTrajectory = matchPitch.trajectoryOptions != null &&
        matchPitch.trajectoryOptions!.isNotEmpty;
    final hasFriction =
        matchPitch.frictionText != null && matchPitch.frictionText!.isNotEmpty;
    final hasVerdict =
        matchPitch.verdictText != null && matchPitch.verdictText!.isNotEmpty;

    if (!hasVibe &&
        !hasComplement &&
        !hasTrajectory &&
        !hasFriction &&
        !hasVerdict) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // The Vibe
        if (hasVibe) ...[
          _PitchCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFE11D48),
            title: "The Vibe",
            backgroundColor: const Color(0xFF1A0A0F),
            borderColor: const Color(0xFF881337),
            child: _QuoteText(text: matchPitch.vibeText!),
          ),
          const SizedBox(height: 12),
        ],

        // Your Trajectory (trajectoryOptions)
        if (hasTrajectory) ...[
          _PitchCard(
            icon: Icons.timeline_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: "Your Trajectory",
            subtitleWidget: const _SubLabel(
              label: "WHAT I SEE FOR YOU TWO",
              color: Color(0xFF7C3AED),
            ),
            backgroundColor: const Color(0xFF0E0A1A),
            borderColor: const Color(0xFF4C1D95),
            child: Column(
              children: matchPitch.trajectoryOptions!
                  .map((opt) => _BulletItem(
                        text: opt,
                        color: const Color(0xFF7C3AED),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Her Journey So Far (complementText)
        if (hasComplement) ...[
          _PitchCard(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF0EA5E9),
            title: "Her Journey So Far",
            backgroundColor: const Color(0xFF0A1520),
            borderColor: const Color(0xFF0C4A6E),
            child: _BodyText(text: matchPitch.complementText!),
          ),
          const SizedBox(height: 12),
        ],

        // The Friction
        if (hasFriction) ...[
          _PitchCard(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: "The Friction",
            backgroundColor: const Color(0xFF1A1200),
            borderColor: const Color(0xFF78350F),
            child: _BodyText(text: matchPitch.frictionText!),
          ),
          const SizedBox(height: 12),
        ],

        // The Jiffy Verdict
        if (hasVerdict) ...[
          _PitchCard(
            icon: Icons.gavel_rounded,
            iconColor: const Color(0xFF10B981),
            title: "The Jiffy Verdict",
            backgroundColor: const Color(0xFF051510),
            borderColor: const Color(0xFF064E3B),
            child: _VerdictText(text: matchPitch.verdictText!),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SubLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SubLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final Widget? subtitleWidget;

  const _PitchCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.subtitleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitleWidget != null) ...[
            const SizedBox(height: 10),
            subtitleWidget!,
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _QuoteText extends StatelessWidget {
  final String text;
  const _QuoteText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: const Color(0xFFE11D48).withValues(alpha: 0.5),
                height: 0.6,
              ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.5,
          ),
    );
  }
}

class _VerdictText extends StatelessWidget {
  final String text;
  const _VerdictText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.arrow_right_rounded, size: 18, color: color),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
