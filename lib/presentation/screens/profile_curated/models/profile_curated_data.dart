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
  final String? aboutMe;

  const ProfileCuratedData({
    required this.name,
    required this.age,
    required this.subtitle,
    this.avatarUrl,
    required this.personalityTraits,
    required this.interests,
    required this.conversationStyleDescription,
    this.aboutMe,
  });

  /// Creates a copy with modified fields.
  ///
  /// For [avatarUrl], use a function to distinguish between "not provided"
  /// and "explicitly set to null". Example:
  /// - `copyWith()` - keeps existing avatarUrl
  /// - `copyWith(avatarUrl: () => 'new_url')` - sets new URL
  /// - `copyWith(avatarUrl: () => null)` - clears the avatar URL
  ProfileCuratedData copyWith({
    String? name,
    int? age,
    String? subtitle,
    String? Function()? avatarUrl,
    List<String>? personalityTraits,
    List<String>? interests,
    String? conversationStyleDescription,
    String? aboutMe,
  }) {
    return ProfileCuratedData(
      name: name ?? this.name,
      age: age ?? this.age,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      interests: interests ?? this.interests,
      conversationStyleDescription:
          conversationStyleDescription ?? this.conversationStyleDescription,
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }
}
