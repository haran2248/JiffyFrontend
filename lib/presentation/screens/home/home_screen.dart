import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:jiffy/presentation/screens/chat/chat_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/home/viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/presentation/screens/home/widgets/story_item_widget.dart';
import 'package:jiffy/presentation/screens/home/widgets/suggestion_card_widget.dart';
import 'package:jiffy/presentation/screens/profile/profile_helpers.dart';
import 'package:jiffy/presentation/screens/stories/data/stories_repository.dart';
import 'package:jiffy/presentation/screens/stories/story_api_helpers.dart';
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
                        _buildStoriesSection(context, state.data!.stories, ref),

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

                        /*
                        // Trending in your area Section
                        if (state.data!.trendingItems.isNotEmpty)
                          _buildTrendingSection(
                            context,
                            state.data!.trendingItems,
                          ),

                        const SizedBox(height: 24),
                        */

                        // Current Matches Section
                        _buildCurrentMatchesSection(
                          context,
                          state.data!.matches,
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

  Widget _buildStoriesSection(
    BuildContext context,
    List<StoryItem> stories,
    WidgetRef ref,
  ) {
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
          final story = stories[index];
          return StoryItemWidget(
            story: story,
            onTap: () async {
              if (story.isUserStory) {
                // User's own story - check if they have stories
                final repository = ref.read(storiesRepositoryProvider);
                try {
                  final userStoriesJson = await repository.fetchUserStories();

                  if (context.mounted) {
                    if (userStoriesJson.isNotEmpty) {
                      // User has stories - show options to view or add new
                      _showUserStoryOptions(context, ref, userStoriesJson);
                    } else {
                      // No stories - open creation screen directly
                      context.navigation.pushNamed(RouteNames.storyCreation);
                    }
                  }
                } catch (e) {
                  // On error, default to opening creation screen
                  if (context.mounted) {
                    context.navigation.pushNamed(RouteNames.storyCreation);
                  }
                }
              } else {
                // Other user's story - fetch actual stories from API
                final repository = ref.read(storiesRepositoryProvider);
                try {
                  final storiesJson = await repository.fetchStories();

                  if (context.mounted) {
                    // Convert API response to Story objects
                    final allStories =
                        StoryApiHelpers.storiesFromApiJson(storiesJson);

                    // Filter stories for this specific user and group them
                    final userStories = allStories
                        .where((s) => s.userId == story.userId)
                        .toList();

                    if (userStories.isNotEmpty) {
                      try {
                        // Group multiple stories into one Story object with multiple contents
                        final groupedStory = StoryApiHelpers.groupStoriesByUser(
                          userStories,
                          story.userId,
                        );

                        context.navigation.pushNamed(
                          RouteNames.storyViewer,
                          extra: {
                            'stories': [groupedStory],
                            'initialStoryIndex': 0,
                            'initialContentIndex': 0,
                          },
                        );
                      } on ArgumentError catch (e) {
                        // Handle ArgumentError from groupStoriesByUser
                        debugPrint('Error grouping match stories: $e');
                        // Fallback: use ungrouped stories
                        context.navigation.pushNamed(
                          RouteNames.storyViewer,
                          extra: {
                            'stories': userStories,
                            'initialStoryIndex': 0,
                            'initialContentIndex': 0,
                          },
                        );
                      } catch (e) {
                        // Handle any other exception
                        debugPrint(
                            'Unexpected error grouping match stories: $e');
                        // Fallback: use ungrouped stories
                        context.navigation.pushNamed(
                          RouteNames.storyViewer,
                          extra: {
                            'stories': userStories,
                            'initialStoryIndex': 0,
                            'initialContentIndex': 0,
                          },
                        );
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('Error fetching match stories: $e');
                  // On error, do nothing (user can try again)
                }
              }
            },
          );
        },
      ),
    );
  }

  void _showUserStoryOptions(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> userStoriesJson,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Capture stable context for navigation (outer screen context, not builder context)
    final stableContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // View Stories option
              ListTile(
                leading: Icon(Icons.visibility, color: colorScheme.primary),
                title: Text(
                  'View Stories',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  // Convert stories before popping
                  final allUserStories = userStoriesJson
                      .map((json) => StoryApiHelpers.storyFromApiJson(json))
                      .toList();

                  // Get current user ID to group stories
                  final currentUser =
                      ref.read(authRepositoryProvider).currentUser;
                  if (currentUser != null && allUserStories.isNotEmpty) {
                    // Filter stories to ensure they belong to current user before grouping
                    final userStories = allUserStories
                        .where((s) => s.userId == currentUser.uid)
                        .toList();

                    try {
                      // Group all user stories into a single Story object with multiple contents
                      final groupedStory = StoryApiHelpers.groupStoriesByUser(
                        userStories,
                        currentUser.uid,
                      );

                      Navigator.of(sheetContext).pop();
                      // Use stable context for navigation
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (stableContext.mounted) {
                          stableContext.navigation.pushNamed(
                            RouteNames.storyViewer,
                            extra: {
                              'stories': [groupedStory],
                              'initialStoryIndex': 0,
                              'initialContentIndex': 0,
                            },
                          );
                        }
                      });
                    } on ArgumentError catch (e) {
                      // Handle ArgumentError from groupStoriesByUser
                      debugPrint('Error grouping stories: $e');
                      // Fallback: use original behavior if grouping fails
                      Navigator.of(sheetContext).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (stableContext.mounted) {
                          stableContext.navigation.pushNamed(
                            RouteNames.storyViewer,
                            extra: {
                              'stories': allUserStories,
                              'initialStoryIndex': 0,
                              'initialContentIndex': 0,
                            },
                          );
                        }
                      });
                    } catch (e) {
                      // Handle any other exception
                      debugPrint('Unexpected error grouping stories: $e');
                      // Fallback: use original behavior if grouping fails
                      Navigator.of(sheetContext).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (stableContext.mounted) {
                          stableContext.navigation.pushNamed(
                            RouteNames.storyViewer,
                            extra: {
                              'stories': allUserStories,
                              'initialStoryIndex': 0,
                              'initialContentIndex': 0,
                            },
                          );
                        }
                      });
                    }
                  } else {
                    // Fallback: use original behavior if no user or no stories
                    Navigator.of(sheetContext).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (stableContext.mounted) {
                        stableContext.navigation.pushNamed(
                          RouteNames.storyViewer,
                          extra: {
                            'stories': allUserStories,
                            'initialStoryIndex': 0,
                            'initialContentIndex': 0,
                          },
                        );
                      }
                    });
                  }
                },
              ),
              // Add New Story option
              ListTile(
                leading: Icon(Icons.add_circle, color: colorScheme.primary),
                title: Text(
                  'Add New Story',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  // Use stable context for navigation
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (stableContext.mounted) {
                      stableContext.navigation
                          .pushNamed(RouteNames.storyCreation);
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Suggestions for the Day',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.pushNamed(RouteNames.discover),
                child: Text(
                  "See All",
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE040FB), // Accent color
                  ),
                ),
              ),
            ],
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
                    final profile = ProfileHelpers.suggestionCardToProfileData(
                      suggestions[index],
                    );
                    context.navigation.pushNamed(
                      RouteNames.profileView,
                      pathParameters: {
                        RouteParams.userId: suggestions[index].userId,
                      },
                      extra: profile,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /*
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
  */

  Widget _buildCurrentMatchesSection(
      BuildContext context, List<SuggestionCard> matches) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Use real matches data
    // If empty, we can hide the section or show a "No matches yet" empty state
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Matches',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.goNamed('matches'), // Navigate to Matches tab
                child: Text(
                  "See All",
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE040FB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return SuggestionCardWidget(
                  suggestion: matches[index],
                  onTap: () {
                    final profile = ProfileHelpers.suggestionCardToProfileData(
                      matches[index],
                    );
                    context.navigation.pushNamed(
                      RouteNames.profileView,
                      pathParameters: {
                        RouteParams.userId: matches[index].userId,
                      },
                      extra: profile,
                    );
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
                    context.pushNamed(
                      RouteNames.chat,
                      pathParameters: {
                        RouteParams.userId: ChatConstants.jiffyBotId,
                      },
                      extra: {
                        'name': 'Jiffy AI',
                        'promptText': prompt.promptText,
                      },
                    );
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
