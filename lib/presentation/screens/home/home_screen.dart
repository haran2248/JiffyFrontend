import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/home/viewmodels/home_viewmodel.dart';
import 'package:jiffy/presentation/screens/home/widgets/story_item_widget.dart';
import 'package:jiffy/presentation/screens/home/widgets/suggestion_card_widget.dart';
import 'package:jiffy/presentation/screens/home/widgets/trending_card_widget.dart';
import 'package:jiffy/presentation/widgets/bottom_navigation_bar.dart';
import 'package:jiffy/presentation/widgets/card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          child: state.isLoading && state.data == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show error banner if error exists but data is available
                      if (state.error != null && state.data != null)
                        _buildErrorBanner(context, state.error!, viewModel),

                      // Show full error state only if no data exists
                      if (state.error != null && state.data == null)
                        _buildErrorState(context, state.error!, viewModel)
                      else if (state.data != null) ...[
                        // Stories Section - scrollable
                        _buildStoriesSection(context, state.data!.stories),

                        const SizedBox(height: 16),

                        // New Prompt Section - at top after stories
                        if (state.data!.currentPrompt != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildNewPromptSection(
                              context,
                              state.data!.currentPrompt!,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Suggestions for the Day Section
                        if (state.data!.suggestions.isNotEmpty)
                          _buildSuggestionsSection(
                            context,
                            state.data!.suggestions,
                          ),

                        const SizedBox(height: 24),

                        // Trending in your area Section
                        if (state.data!.trendingItems.isNotEmpty)
                          _buildTrendingSection(
                            context,
                            state.data!.trendingItems,
                          ),

                        const SizedBox(height: 24),

                        // Current Matches Section
                        _buildCurrentMatchesSection(
                          context,
                          state.data!.suggestions,
                        ),

                        const SizedBox(height: 80), // Space for bottom nav
                      ],
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(
        currentRoute: AppRoutes.home,
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    String error,
    HomeViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to refresh: $error',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => viewModel.loadHomeData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    HomeViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading content',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.loadHomeData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection(BuildContext context, List<StoryItem> stories) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return StoryItemWidget(
            story: stories[index],
            onTap: () {
              // TODO: Handle story tap
            },
          );
        },
      ),
    );
  }

  Widget _buildSuggestionsSection(
      BuildContext context, List<SuggestionCard> suggestions) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions for the Day',
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return SuggestionCardWidget(
                  suggestion: suggestions[index],
                  onTap: () {
                    // TODO: Navigate to profile detail
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(
      BuildContext context, List<TrendingItem> trendingItems) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending in your area',
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover what\'s popular with singles near you',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...trendingItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TrendingCardWidget(
                trendingItem: item,
                onTap: () {
                  // TODO: Handle trending item tap
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMatchesSection(
      BuildContext context, List<SuggestionCard> matches) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Use suggestions as matches for now (or create separate matches data)
    final matchUsers = matches.take(4).toList();

    if (matchUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Matches',
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: matchUsers.length,
              itemBuilder: (context, index) {
                return SuggestionCardWidget(
                  suggestion: matchUsers[index],
                  onTap: () {
                    // TODO: Navigate to match profile
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPromptSection(BuildContext context, MatchPrompt prompt) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SystemCard(
      padding: const EdgeInsets.all(16),
      isGlass: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Prompt',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prompt.promptText,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Handle prompt answer
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'Answer Now',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
