import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/match_item.dart';
import '../models/matches_filter.dart';

import 'package:jiffy/presentation/screens/chat/data/chat_repository.dart';
import 'package:jiffy/presentation/screens/chat/models/chat_message.dart'; // Import ChatMessage
import '../data/matches_repository.dart';

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
          // Only matches with existing conversations, plus Jiffy AI
          return match.hasConversation || match.isJiffyAi;
        case MatchesFilter.waitingForYou:
          // Matches WITHOUT conversations (excluding Jiffy AI as it's a "chat")
          return !match.hasConversation && !match.isJiffyAi;
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
      case MatchesFilter.waitingForYou:
        // Sort by match date (newest first)
        result.sort((a, b) {
          if (a.isJiffyAi) return -1;
          if (b.isJiffyAi) return 1;
          final aTime = a.matchedAt ?? DateTime(1970);
          final bTime = b.matchedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
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
    // Determine initial state. We can trigger loadMatches immediately or wait.
    // Ideally we should start loading mock data is removed.
    // But build cannot be async.
    // We can return a loading state and trigger loadMatches in a microtask.
    Future.microtask(() => loadMatches());

    return const MatchesState(
      isLoading: true,
    );
  }

  /// Set the current filter tab
  void setFilter(MatchesFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Load matches from API and Firestore
  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final matchesRepo = ref.read(matchesRepositoryProvider);
      final chatRepo = ref.read(chatRepositoryProvider);

      final rawMatches = await matchesRepo.fetchMatches();

      final List<MatchItem> matchItems = [];

      // Process each match
      for (final matchData in rawMatches) {
        final String uid = matchData['uid']?.toString() ?? '';
        if (uid.isEmpty) continue;

        final String name = matchData['name'] ?? 'User';
        final String? imageUrl = _getImageUrl(matchData);

        // Fetch last message to determine "Current Chats" vs "Matches"
        String? lastMessage;
        DateTime? lastMessageTime;

        try {
          // This returns "Start your conversation" if no message
          final ChatMessage? msg = await chatRepo.getLastMessage(uid);
          if (msg != null) {
            lastMessage = msg.message;
            lastMessageTime = msg.timestamp;
          }
        } catch (_) {}

        matchItems.add(MatchItem(
          id: uid,
          name: name,
          imageUrl: imageUrl,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          isJiffyAi: false, // Jiffy AI logic to be added later if needed
          compatibilityScore: 0.0, // Not available in basic endpoint
          matchedAt: DateTime.now(), // Not available in basic endpoint
          hasUnread: false, // Need separate call
        ));
      }

      // Add Jiffy AI manually if desired (keeping mock logic for it)
      final now = DateTime.now();
      matchItems.insert(
          0,
          MatchItem(
            id: 'jiffy-ai',
            name: 'Jiffy AI',
            imageUrl: null,
            lastMessage: "Hey! 👋 I'm here to help you ...",
            lastMessageTime: now.subtract(const Duration(hours: 12)),
            isJiffyAi: true,
            compatibilityScore: 1.0,
            matchedAt: now.subtract(const Duration(days: 30)),
          ));

      state = state.copyWith(
        matches: matchItems,
        isLoading: false,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to load matches: $e',
      );
    }
  }

  String? _getImageUrl(Map<String, dynamic> user) {
    String? currentImageId;

    if (user['imageId'] != null && user['imageId'].toString().isNotEmpty) {
      currentImageId = user['imageId'].toString();
    } else if (user['images'] != null &&
        user['images'] is List &&
        (user['images'] as List).isNotEmpty) {
      currentImageId = (user['images'] as List)[0]?.toString();
    } else if (user['imageIds'] != null &&
        user['imageIds'] is List &&
        (user['imageIds'] as List).isNotEmpty) {
      currentImageId = (user['imageIds'] as List)[0]?.toString();
    } else if (user['firstImageId'] != null) {
      currentImageId = user['firstImageId']?.toString();
    } else {
      return null;
    }

    if (currentImageId == null || currentImageId.isEmpty) {
      return null;
    }

    return "https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$currentImageId";
  }
}
