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

class ProfileData {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? location; // e.g., "New York, NY"
  final String? college;
  final String? work;
  final String? jobTitle;
  final String? height;
  final String? drinking;
  final String? smoking;
  final String? diet;
  final String? relationshipGoals;
  final String? preferredGender;
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
  final String? gender; // E.g., 'Woman', 'Man'
  final bool isWaitlisted;

  const ProfileData({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.location,
    this.college,
    this.work,
    this.jobTitle,
    this.height,
    this.drinking,
    this.smoking,
    this.diet,
    this.relationshipGoals,
    this.preferredGender,
    this.photos = const [],
    required this.bio,
    this.relationshipPreview,
    this.comparisonInsights = const [],
    this.interests = const [],
    this.traits = const [],
    this.conversationStyle,
    this.conversationStarter,
    this.onboardingStatus,
    this.gender,
    this.isWaitlisted = false,
  });

  ProfileData copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    Object? location = _sentinel,
    Object? college = _sentinel,
    Object? work = _sentinel,
    Object? jobTitle = _sentinel,
    Object? height = _sentinel,
    Object? drinking = _sentinel,
    Object? smoking = _sentinel,
    Object? diet = _sentinel,
    Object? relationshipGoals = _sentinel,
    Object? preferredGender = _sentinel,
    List<Photo>? photos,
    String? bio,
    Object? relationshipPreview = _sentinel,
    List<ComparisonInsight>? comparisonInsights,
    List<String>? interests,
    List<String>? traits,
    Object? conversationStyle = _sentinel,
    Object? conversationStarter = _sentinel,
    Object? onboardingStatus = _sentinel,
    String? gender,
    bool? isWaitlisted,
  }) {
    return ProfileData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      location:
          identical(location, _sentinel) ? this.location : location as String?,
      college:
          identical(college, _sentinel) ? this.college : college as String?,
      work: identical(work, _sentinel) ? this.work : work as String?,
      jobTitle: identical(jobTitle, _sentinel) ? this.jobTitle : jobTitle as String?,
      height: identical(height, _sentinel) ? this.height : height as String?,
      drinking: identical(drinking, _sentinel) ? this.drinking : drinking as String?,
      smoking: identical(smoking, _sentinel) ? this.smoking : smoking as String?,
      diet: identical(diet, _sentinel) ? this.diet : diet as String?,
      relationshipGoals: identical(relationshipGoals, _sentinel) ? this.relationshipGoals : relationshipGoals as String?,
      preferredGender: identical(preferredGender, _sentinel) ? this.preferredGender : preferredGender as String?,
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
      gender: gender ?? this.gender,
      isWaitlisted: isWaitlisted ?? this.isWaitlisted,
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
