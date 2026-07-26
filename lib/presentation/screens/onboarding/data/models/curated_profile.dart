/// Model class representing curated profile data from AI analysis.
class CuratedProfileInsight {
  final String title;
  final String description;

  CuratedProfileInsight({required this.title, required this.description});

  factory CuratedProfileInsight.fromJson(Map<String, dynamic> json) {
    return CuratedProfileInsight(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

/// Model class representing curated profile data from AI analysis.
class CuratedProfile {
  final List<String> personalityTraits;
  final List<String> interests;
  final String conversationStyleDescription;
  final String? aboutMe;
  final List<CuratedProfileInsight> insights;

  CuratedProfile({
    required this.personalityTraits,
    required this.interests,
    required this.conversationStyleDescription,
    this.aboutMe,
    this.insights = const [],
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
      aboutMe: json['aboutMe'] as String?,
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => CuratedProfileInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalityTraits': personalityTraits,
      'interests': interests,
      'conversationStyleDescription': conversationStyleDescription,
      if (aboutMe != null) 'aboutMe': aboutMe,
      'insights': insights.map((e) => e.toJson()).toList(),
    };
  }

  CuratedProfile copyWith({
    List<String>? personalityTraits,
    List<String>? interests,
    String? conversationStyleDescription,
    String? aboutMe,
    List<CuratedProfileInsight>? insights,
  }) {
    return CuratedProfile(
      personalityTraits: personalityTraits ?? this.personalityTraits,
      interests: interests ?? this.interests,
      conversationStyleDescription:
          conversationStyleDescription ?? this.conversationStyleDescription,
      aboutMe: aboutMe ?? this.aboutMe,
      insights: insights ?? this.insights,
    );
  }
}
