/// Filter options for the matches screen tabs.
enum MatchesFilter {
  /// Existing conversations with messages
  currentChats,

  /// All matched users (new and existing)
  matches,

  /// Highest compatibility score matches
  mostCompatible,
}

/// Extension to provide display labels for each filter.
extension MatchesFilterExtension on MatchesFilter {
  String get label {
    switch (this) {
      case MatchesFilter.currentChats:
        return 'Current Chats';
      case MatchesFilter.matches:
        return 'Matches';
      case MatchesFilter.mostCompatible:
        return 'Most Compatible';
    }
  }
}
