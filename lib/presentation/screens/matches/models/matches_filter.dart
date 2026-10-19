/// Filter options for the matches screen tabs.
enum MatchesFilter {
  /// Existing conversations with messages
  currentChats,

  /// Incoming requests from stories and suggestions where recipient hasn't replied yet
  requested,
}

/// Extension to provide display labels for each filter.
extension MatchesFilterExtension on MatchesFilter {
  String get label {
    switch (this) {
      case MatchesFilter.currentChats:
        return 'Current Chats';
      case MatchesFilter.requested:
        return 'Requested';
    }
  }
}
