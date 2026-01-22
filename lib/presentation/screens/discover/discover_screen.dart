import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/presentation/screens/home/viewmodels/home_viewmodel.dart';
import 'package:jiffy/presentation/screens/home/widgets/suggestion_card_widget.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);

    // In a real app we might want a dedicated provider, but reusing home data is fine for now
    final allSuggestions = homeState.data?.suggestions ?? [];

    final topPicks = allSuggestions.where((s) => s.isTopPick).toList();
    final otherSuggestions = allSuggestions.where((s) => !s.isTopPick).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14), // AppColors.midnightPlum
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Today's Suggestions",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Top Picks Header
                if (topPicks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[400], size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Top Picks",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top Picks Grid
                if (topPicks.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final suggestion = topPicks[index];
                          return _TopPickCard(
                            suggestion: suggestion,
                            onTap: () =>
                                _navigateToProfile(context, suggestion),
                          );
                        },
                        childCount: topPicks.length,
                      ),
                    ),
                  ),

                // More Suggestions Header
                if (otherSuggestions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                      child: Text(
                        "More Suggestions",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // More Suggestions List
                if (otherSuggestions.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final suggestion = otherSuggestions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SuggestionCardWidget(
                              suggestion: suggestion,
                              onTap: () =>
                                  _navigateToProfile(context, suggestion),
                            ),
                          );
                        },
                        childCount: otherSuggestions.length,
                      ),
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
    );
  }

  void _navigateToProfile(BuildContext context, SuggestionCard suggestion) {
    // Navigate to profile view via GoRouter
    // Construct minimal ProfileData from suggestion
    final profile = ProfileData(
      id: suggestion.userId,
      userId: suggestion.userId,
      name: suggestion.name,
      age: suggestion.age,
      bio: suggestion.bio,
      photos:
          suggestion.imageUrl != null ? [Photo(url: suggestion.imageUrl!)] : [],
      // Other fields would be null or defaults
      location: "San Francisco, CA", // Mock location
    );

    context.pushNamed(
      'profile-view',
      extra: profile,
    );
  }
}

class _TopPickCard extends StatelessWidget {
  final SuggestionCard suggestion;
  final VoidCallback onTap;

  const _TopPickCard({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1E1E24), // Surface color
          image: suggestion.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(suggestion.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${suggestion.name}, ${suggestion.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flash_on,
                          color: Color(0xFF8E24AA), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${(suggestion.interests.isNotEmpty) ? suggestion.interests.first : "Match"}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Pick Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE040FB), // Accent color
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
