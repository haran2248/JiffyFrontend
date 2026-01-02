import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/widgets/bottom_navigation_bar.dart';
import 'viewmodels/matches_viewmodel.dart';
import 'widgets/matches_tab_bar.dart';
import 'widgets/match_card_widget.dart';

/// Main matches screen with tabbed filters.
///
/// Displays matches in three tabs:
/// - Current Chats: Existing conversations
/// - Matches: All matched users
/// - Most Compatible: Sorted by compatibility score
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchesViewModelProvider);
    final viewModel = ref.read(matchesViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Matches',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              // TODO: Implement search functionality
              _showSearchDialog(context, viewModel);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          MatchesTabBar(
            selectedFilter: state.currentFilter,
            onFilterChanged: viewModel.setFilter,
          ),
          // Matches list
          Expanded(
            child: _buildContent(context, state, viewModel),
          ),
        ],
      ),
      bottomNavigationBar:
          const BottomNavigationBarWidget(currentRoute: AppRoutes.matches),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MatchesState state,
    MatchesViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: viewModel.loadMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final matches = state.filteredMatches;

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new matches',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadMatches,
      color: colorScheme.primary,
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return MatchCardWidget(
            match: match,
            onTap: () {
              context.pushNamed(
                RouteNames.chat,
                pathParameters: {'userId': match.id},
                extra: {
                  'name': match.name,
                  'image': match.imageUrl,
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context, MatchesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by name or tag...',
            ),
            onChanged: viewModel.setSearchQuery,
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.setSearchQuery('');
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
