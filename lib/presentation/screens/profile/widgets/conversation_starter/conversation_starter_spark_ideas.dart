import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/spark_idea_card.dart";

/// Spark ideas section with scrollable cards
class ConversationStarterSparkIdeas extends StatelessWidget {
  final ProfileData profile;
  final Function(String)? onCardTap;

  const ConversationStarterSparkIdeas({
    super.key,
    required this.profile,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spark Ideas header
        Text(
          "Spark Ideas for you",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Spark idea cards (horizontal scrollable)
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SparkIdeaCard(
                icon: Icons.location_on,
                category: "Based on Local Spots",
                message: "I see you love hiking at Mission Peak. What's your favorite trail?",
                onTap: onCardTap != null
                    ? () => onCardTap!("I see you love hiking at Mission Peak. What's your favorite trail?")
                    : null,
              ),
              const SizedBox(width: 8),
              SparkIdeaCard(
                icon: Icons.favorite,
                category: "Based on Interests",
                message: "We both love craft beer! Have you tried any new breweries lately?",
                onTap: onCardTap != null
                    ? () => onCardTap!("We both love craft beer! Have you tried any new breweries lately?")
                    : null,
              ),
              const SizedBox(width: 8),
              SparkIdeaCard(
                icon: Icons.auto_awesome,
                category: "AI Generated",
                message: profile.conversationStarter ??
                    "Ask me about my most recent travel mishap!",
                onTap: onCardTap != null
                    ? () => onCardTap!(profile.conversationStarter ??
                        "Ask me about my most recent travel mishap!")
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

