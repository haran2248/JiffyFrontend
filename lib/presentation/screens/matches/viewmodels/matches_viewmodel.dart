import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/match_item.dart';
import '../models/matches_filter.dart';

part 'matches_viewmodel.g.dart';

/// State for the matches screen
class MatchesState {
  final MatchesFilter currentFilter;
  final List<MatchItem> matches;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const MatchesState({
    this.currentFilter = MatchesFilter.currentChats,
    this.matches = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  MatchesState copyWith({
    MatchesFilter? currentFilter,
    List<MatchItem>? matches,
    bool? isLoading,
    String? Function()? error,
    String? searchQuery,
  }) {
    return MatchesState(
      currentFilter: currentFilter ?? this.currentFilter,
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get filtered matches based on current filter and search query
  List<MatchItem> get filteredMatches {
    var result = matches.where((match) {
      // Apply filter
      switch (currentFilter) {
        case MatchesFilter.currentChats:
          // Only matches with existing conversations
          return match.hasConversation || match.isJiffyAi;
        case MatchesFilter.matches:
          // All matches
          return true;
        case MatchesFilter.mostCompatible:
          // Has compatibility score
          return match.compatibilityScore != null || match.isJiffyAi;
      }
    }).toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((match) {
        return match.name.toLowerCase().contains(query) ||
            match.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Sort based on filter
    switch (currentFilter) {
      case MatchesFilter.currentChats:
        // Sort by last message time (most recent first), Jiffy AI always on top
        result.sort((a, b) {
          if (a.isJiffyAi) return -1;
          if (b.isJiffyAi) return 1;
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        break;
      case MatchesFilter.matches:
        // Sort by match date (newest first)
        result.sort((a, b) {
          if (a.isJiffyAi) return -1;
          if (b.isJiffyAi) return 1;
          final aTime = a.matchedAt ?? DateTime(1970);
          final bTime = b.matchedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        break;
      case MatchesFilter.mostCompatible:
        // Sort by compatibility score (highest first)
        result.sort((a, b) {
          if (a.isJiffyAi) return -1;
          if (b.isJiffyAi) return 1;
          final aScore = a.compatibilityScore ?? 0;
          final bScore = b.compatibilityScore ?? 0;
          return bScore.compareTo(aScore);
        });
        break;
    }

    return result;
  }
}

@riverpod
class MatchesViewModel extends _$MatchesViewModel {
  @override
  MatchesState build() {
    // Schedule mock data loading after initial state is set
    Future.microtask(() => _loadMockData());
    return const MatchesState(isLoading: true);
  }

  /// Set the current filter tab
  void setFilter(MatchesFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Load matches (mock data for now, API-ready interface)
  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(milliseconds: 300));
      _loadMockData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to load matches: $e',
      );
    }
  }

  void _loadMockData() {
    final now = DateTime.now();
    final mockMatches = [
      // Jiffy AI Assistant
      MatchItem(
        id: 'jiffy-ai',
        name: 'Jiffy AI',
        imageUrl: null, // Will use icon
        lastMessage: "Hey! 👋 I'm here to help you ...",
        lastMessageTime: now.subtract(const Duration(hours: 12)),
        isJiffyAi: true,
        compatibilityScore: 1.0,
        matchedAt: now.subtract(const Duration(days: 30)),
      ),
      // Mock matches with conversations
      MatchItem(
        id: '1',
        name: 'Alex',
        age: null,
        imageUrl: 'https://i.pravatar.cc/150?img=1',
        lastMessage: 'Yes! I was there last weekend. ...',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        tags: [],
        compatibilityScore: 0.92,
        matchedAt: now.subtract(const Duration(days: 2)),
        hasUnread: true,
      ),
      MatchItem(
        id: '2',
        name: 'Chloe',
        age: 25,
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        lastMessage: 'Witty banter over late-night diners',
        lastMessageTime: now.subtract(const Duration(hours: 12)),
        tags: ['Foodie', 'Night Owl'],
        compatibilityScore: 0.88,
        matchedAt: now.subtract(const Duration(days: 3)),
        bio: 'Witty banter over late-night diners',
      ),
      MatchItem(
        id: '3',
        name: 'Jessica',
        age: 28,
        imageUrl: 'https://i.pravatar.cc/150?img=9',
        lastMessage: 'Deep conversations & shared adventures',
        lastMessageTime: now.subtract(const Duration(hours: 17)),
        tags: ['Creative', 'Traveler', 'Humor'],
        compatibilityScore: 0.95,
        matchedAt: now.subtract(const Duration(days: 1)),
        bio: 'Deep conversations & shared adventures',
      ),
      MatchItem(
        id: '4',
        name: 'Maya',
        age: 29,
        imageUrl: 'https://i.pravatar.cc/150?img=16',
        lastMessage: 'Exploring art galleries and quiet cafes',
        lastMessageTime: now.subtract(const Duration(hours: 23)),
        tags: ['Art', 'Coffee', 'Introvert'],
        compatibilityScore: 0.85,
        matchedAt: now.subtract(const Duration(days: 5)),
        bio: 'Exploring art galleries and quiet cafes',
      ),
      // Matches without conversations yet (for "Matches" tab)
      MatchItem(
        id: '5',
        name: 'Sophie',
        age: 26,
        imageUrl: 'https://i.pravatar.cc/150?img=20',
        tags: ['Yoga', 'Vegan', 'Travel'],
        compatibilityScore: 0.91,
        matchedAt: now.subtract(const Duration(hours: 5)),
        bio: 'Adventure seeker with a calm soul',
      ),
      MatchItem(
        id: '6',
        name: 'Emma',
        age: 24,
        imageUrl: 'https://i.pravatar.cc/150?img=23',
        tags: ['Music', 'Dancing', 'Brunch'],
        compatibilityScore: 0.78,
        matchedAt: now.subtract(const Duration(hours: 8)),
        bio: 'Living for live music and spontaneous trips',
      ),
    ];

    state = state.copyWith(
      matches: mockMatches,
      isLoading: false,
      error: () => null,
    );
  }
}
