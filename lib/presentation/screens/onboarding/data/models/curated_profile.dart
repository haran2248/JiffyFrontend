/// Model class representing curated profile data from AI analysis.
class CuratedProfile {
  final List<String> personalityTraits;
  final List<String> interests;
  final String conversationStyleDescription;

  CuratedProfile({
    required this.personalityTraits,
    required this.interests,
    required this.conversationStyleDescription,
  });

  factory CuratedProfile.fromJson(Map<String, dynamic> json) {
    return CuratedProfile(
      personalityTraits: (json['personalityTraits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      conversationStyleDescription:
          json['conversationStyleDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalityTraits': personalityTraits,
      'interests': interests,
      'conversationStyleDescription': conversationStyleDescription,
    };
  }

  CuratedProfile copyWith({
    List<String>? personalityTraits,
    List<String>? interests,
    String? conversationStyleDescription,
  }) {
    return CuratedProfile(
      personalityTraits: personalityTraits ?? this.personalityTraits,
      interests: interests ?? this.interests,
      conversationStyleDescription:
          conversationStyleDescription ?? this.conversationStyleDescription,
    );
  }
}
