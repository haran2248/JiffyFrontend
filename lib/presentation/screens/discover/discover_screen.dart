import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/app_routes.dart";
import "package:jiffy/core/navigation/navigation_service.dart";
import "package:jiffy/presentation/screens/home/models/home_data.dart";
import "package:jiffy/presentation/screens/home/widgets/suggestion_card_widget.dart";
import "package:jiffy/presentation/screens/profile/profile_helpers.dart";
import "package:jiffy/presentation/widgets/bottom_navigation_bar.dart";

/// Discover screen showing profiles to browse
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Load actual discover profiles from viewmodel
    // For now, using mock data
    final mockProfiles = <SuggestionCard>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Discover",
          style: textTheme.displayMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: mockProfiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No profiles to discover",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: mockProfiles.length,
              itemBuilder: (context, index) {
                return SuggestionCardWidget(
                  suggestion: mockProfiles[index],
                  onTap: () {
                    final profile = ProfileHelpers.suggestionCardToProfileData(
                      mockProfiles[index],
                    );
                    context.navigation.pushNamed(
                      'profile-view',
                      pathParameters: {
                        'userId': mockProfiles[index].userId,
                      },
                      extra: profile,
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const BottomNavigationBarWidget(
        currentRoute: AppRoutes.discover,
      ),
    );
  }
}

