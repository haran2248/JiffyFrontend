/// Photo model with URL and optional caption
class Photo {
  final String url; // URL to fetch the photo
  final String? caption; // Optional caption text

  const Photo({
    required this.url,
    this.caption,
  });

  Photo copyWith({
    String? url,
    String? Function()? caption,
  }) {
    return Photo(
      url: url ?? this.url,
      caption: caption != null ? caption() : this.caption,
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
  });

  ProfileData copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    String? Function()? location,
    List<Photo>? photos,
    String? bio,
    String? Function()? relationshipPreview,
    List<ComparisonInsight>? comparisonInsights,
    List<String>? interests,
    List<String>? traits,
    String? Function()? conversationStyle,
    String? Function()? conversationStarter,
  }) {
    return ProfileData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location != null ? location() : this.location,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      relationshipPreview: relationshipPreview != null
          ? relationshipPreview()
          : this.relationshipPreview,
      comparisonInsights: comparisonInsights ?? this.comparisonInsights,
      interests: interests ?? this.interests,
      traits: traits ?? this.traits,
      conversationStyle: conversationStyle != null
          ? conversationStyle()
          : this.conversationStyle,
      conversationStarter: conversationStarter != null
          ? conversationStarter()
          : this.conversationStarter,
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
