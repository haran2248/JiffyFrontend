const Object _sentinel = Object();

/// Photo model with URL and optional caption
class Photo {
  final String url; // URL to fetch the photo
  final String? caption; // Optional caption text
  final String? id; // Original imageId from backend
  final int? backendSlot; // 1-4 for positional avatars

  const Photo({
    required this.url,
    this.caption,
    this.id,
    this.backendSlot,
  });

  Photo copyWith({
    String? url,
    Object? caption = _sentinel,
    Object? id = _sentinel,
    Object? backendSlot = _sentinel,
  }) {
    return Photo(
      url: url ?? this.url,
      caption:
          identical(caption, _sentinel) ? this.caption : caption as String?,
      id: identical(id, _sentinel) ? this.id : id as String?,
      backendSlot: identical(backendSlot, _sentinel)
          ? this.backendSlot
          : backendSlot as int?,
    );
  }
}

/// Profile data model for profile view screen
class ProfileData {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? location; // e.g., "New York, NY"
  final List<Photo> photos; // Array of photos with URLs and captions
  final String bio;
  final String? relationshipPreview; // Full relationship preview text
  final List<ComparisonInsight>
      comparisonInsights; // Profile comparison insights
  final List<String> interests; // e.g., ["Hiking", "Photography"]
  final List<String> traits; // Personality traits
  final String?
      conversationStyle; // e.g., "Playful wit, balancing deep & thoughtful chats"
  final String? conversationStarter; // Prompt text
  final String? onboardingStatus; // E.g., 'COMPLETED'

  const ProfileData({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.location,
    this.photos = const [],
    required this.bio,
    this.relationshipPreview,
    this.comparisonInsights = const [],
    this.interests = const [],
    this.traits = const [],
    this.conversationStyle,
    this.conversationStarter,
    this.onboardingStatus,
  });

  ProfileData copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    Object? location = _sentinel,
    List<Photo>? photos,
    String? bio,
    Object? relationshipPreview = _sentinel,
    List<ComparisonInsight>? comparisonInsights,
    List<String>? interests,
    List<String>? traits,
    Object? conversationStyle = _sentinel,
    Object? conversationStarter = _sentinel,
    Object? onboardingStatus = _sentinel,
  }) {
    return ProfileData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      location:
          identical(location, _sentinel) ? this.location : location as String?,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      relationshipPreview: identical(relationshipPreview, _sentinel)
          ? this.relationshipPreview
          : relationshipPreview as String?,
      comparisonInsights: comparisonInsights ?? this.comparisonInsights,
      interests: interests ?? this.interests,
      traits: traits ?? this.traits,
      conversationStyle: identical(conversationStyle, _sentinel)
          ? this.conversationStyle
          : conversationStyle as String?,
      conversationStarter: identical(conversationStarter, _sentinel)
          ? this.conversationStarter
          : conversationStarter as String?,
      onboardingStatus: identical(onboardingStatus, _sentinel)
          ? this.onboardingStatus
          : onboardingStatus as String?,
    );
  }
}

/// Comparison insight showing common or uncommon traits between users
class ComparisonInsight {
  final String
      label; // e.g., "Similar conversation style", "Shared sense of humor"
  final InsightType type; // Common or uncommon

  const ComparisonInsight({
    required this.label,
    required this.type,
  });
}

/// Type of comparison insight
enum InsightType {
  common, // Things they have in common
  uncommon, // Things that are different but complementary
}
