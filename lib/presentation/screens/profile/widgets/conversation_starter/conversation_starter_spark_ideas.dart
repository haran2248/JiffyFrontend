import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/conversation_starter_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/spark_idea_card.dart";

/// Spark ideas section with scrollable cards
class ConversationStarterSparkIdeas extends StatelessWidget {
  final ConversationStarterData conversationData;
  final Function(String)? onCardTap;

  const ConversationStarterSparkIdeas({
    super.key,
    required this.conversationData,
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
        conversationData.sparkIdeas.isEmpty
            ? const SizedBox.shrink()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final textScaler = MediaQuery.of(context).textScaler;
                  final baseHeight = 110.0;
                  final scaleFactor = textScaler.scale(1.0);
                  final adaptiveHeight =
                      (baseHeight * scaleFactor).clamp(110.0, 200.0);
                  return SizedBox(
                    height: adaptiveHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: conversationData.sparkIdeas.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final sparkIdea = conversationData.sparkIdeas[index];
                        return SparkIdeaCard(
                          sparkIdea: sparkIdea,
                          onTap: onCardTap != null
                              ? () => onCardTap!(sparkIdea.message)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }
}
