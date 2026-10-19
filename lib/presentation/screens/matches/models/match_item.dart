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

  /// Whether the current user has sent a message in this conversation
  final bool currentUserHasSentMessage;

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
    this.currentUserHasSentMessage = false,
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
    bool? currentUserHasSentMessage,
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
      currentUserHasSentMessage:
          currentUserHasSentMessage ?? this.currentUserHasSentMessage,
      bio: bio != null ? bio() : this.bio,
    );
  }

  /// Helper to check if this match has a conversation started
  bool get hasConversation => lastMessage != null && lastMessage!.isNotEmpty;

  /// When this request was initiated (first message time or match time)
  DateTime? get requestTime => lastMessageTime ?? matchedAt;

  /// Expiration deadline for requested conversations (48 hours from request time)
  DateTime? get expirationDeadline {
    if (requestTime == null) return null;
    return requestTime!.add(const Duration(hours: 48));
  }

  /// Remaining duration before this request expires
  Duration? get timeUntilExpiration {
    if (expirationDeadline == null) return null;
    return expirationDeadline!.difference(DateTime.now());
  }

  /// Whether this request has expired (>48 hours without reply)
  bool get isExpired {
    final remaining = timeUntilExpiration;
    if (remaining == null) return false;
    return remaining.isNegative;
  }

  /// Formatted expiration string for display (e.g., 'Expires in 32h', 'Expires in 45m')
  String? get expirationText {
    final remaining = timeUntilExpiration;
    if (remaining == null) return null;
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours >= 1) {
      return 'Expires in ${remaining.inHours}h';
    } else {
      final mins = remaining.inMinutes;
      return 'Expires in ${mins > 0 ? mins : 1}m';
    }
  }

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
