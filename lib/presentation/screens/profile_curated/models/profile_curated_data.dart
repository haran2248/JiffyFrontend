/// Data model for the curated profile screen.
///
/// Contains all the user profile information displayed on the curated profile
/// review screen before finalizing.
class ProfileCuratedData {
  final String name;
  final int age;
  final String subtitle;
  final String? avatarUrl;
  final List<String> personalityTraits;
  final List<String> interests;
  final String conversationStyleDescription;

  const ProfileCuratedData({
    required this.name,
    required this.age,
    required this.subtitle,
    this.avatarUrl,
    required this.personalityTraits,
    required this.interests,
    required this.conversationStyleDescription,
  });

  /// Creates a copy with modified fields
  ProfileCuratedData copyWith({
    String? name,
    int? age,
    String? subtitle,
    String? avatarUrl,
    List<String>? personalityTraits,
    List<String>? interests,
    String? conversationStyleDescription,
  }) {
    return ProfileCuratedData(
      name: name ?? this.name,
      age: age ?? this.age,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      interests: interests ?? this.interests,
      conversationStyleDescription:
          conversationStyleDescription ?? this.conversationStyleDescription,
    );
  }
}
