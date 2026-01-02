/// Data model representing a match or chat conversation preview.
///
/// This model is designed to be extensible for future API integration.
/// Currently used with mock data, but structured for easy swap to
/// REST API or Firebase Firestore.
class MatchItem {
  /// Unique identifier for the match/conversation
  final String id;

  /// Display name of the matched user
  final String name;

  /// Age of the matched user (nullable for Jiffy AI)
  final int? age;

  /// URL for the user's avatar image
  final String? imageUrl;

  /// Preview of the last message in the conversation
  final String? lastMessage;

  /// Timestamp of the last message
  final DateTime? lastMessageTime;

  /// Interest/personality tags (e.g., "Foodie", "Night Owl")
  final List<String> tags;

  /// Whether this is the Jiffy AI assistant row
  final bool isJiffyAi;

  /// Compatibility score (0.0 - 1.0) for sorting
  final double? compatibilityScore;

  /// When the match was created (for "Matches" tab sorting)
  final DateTime? matchedAt;

  /// Whether there are unread messages
  final bool hasUnread;

  /// Short bio or description
  final String? bio;

  const MatchItem({
    required this.id,
    required this.name,
    this.age,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.tags = const [],
    this.isJiffyAi = false,
    this.compatibilityScore,
    this.matchedAt,
    this.hasUnread = false,
    this.bio,
  });

  /// Creates a copy with updated fields (immutable pattern)
  MatchItem copyWith({
    String? id,
    String? name,
    int? Function()? age,
    String? Function()? imageUrl,
    String? Function()? lastMessage,
    DateTime? Function()? lastMessageTime,
    List<String>? tags,
    bool? isJiffyAi,
    double? Function()? compatibilityScore,
    DateTime? Function()? matchedAt,
    bool? hasUnread,
    String? Function()? bio,
  }) {
    return MatchItem(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age != null ? age() : this.age,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      lastMessage: lastMessage != null ? lastMessage() : this.lastMessage,
      lastMessageTime:
          lastMessageTime != null ? lastMessageTime() : this.lastMessageTime,
      tags: tags ?? this.tags,
      isJiffyAi: isJiffyAi ?? this.isJiffyAi,
      compatibilityScore: compatibilityScore != null
          ? compatibilityScore()
          : this.compatibilityScore,
      matchedAt: matchedAt != null ? matchedAt() : this.matchedAt,
      hasUnread: hasUnread ?? this.hasUnread,
      bio: bio != null ? bio() : this.bio,
    );
  }

  /// Helper to check if this match has a conversation started
  bool get hasConversation => lastMessage != null && lastMessage!.isNotEmpty;

  /// Formatted time ago string for display
  String get timeAgo {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${(diff.inDays / 7).floor()}w';
    }
  }
}
