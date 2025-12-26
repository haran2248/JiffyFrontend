import 'package:flutter/material.dart';
import 'package:jiffy/presentation/widgets/card.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Card widget for trending items
class TrendingCardWidget extends StatelessWidget {
  final TrendingItem trendingItem;
  final VoidCallback? onTap;

  const TrendingCardWidget({
    super.key,
    required this.trendingItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SystemCard(
          padding: const EdgeInsets.all(16),
          onTap:
              null, // Let InkWell handle taps to avoid duplicate gesture detection
          isGlass: false,
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(trendingItem.type, colorScheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trendingItem.iconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trendingItem.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trendingItem.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get background color based on trending item type
  static Color _getBackgroundColor(
    TrendingItemType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case TrendingItemType.hotTake:
        // Orange background for hot take
        return const Color(0xFFFF6B35);
      case TrendingItemType.location:
        // Green background for location
        return const Color(0xFF4CAF50);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
}
