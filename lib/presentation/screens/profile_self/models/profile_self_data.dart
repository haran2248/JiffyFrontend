/// Photo model for self profile with edit capability
class ProfileSelfPhoto {
  final String id;
  final String url;
  final bool isPrimary;
  final int
      backendSlot; // Backend slot (1=firstImageId, 2=secondImageId, 3=thirdImageId, 4=fourthImageId)

  const ProfileSelfPhoto({
    required this.id,
    required this.url,
    this.isPrimary = false,
    required this.backendSlot,
  });

  ProfileSelfPhoto copyWith({
    String? id,
    String? url,
    bool? isPrimary,
    int? backendSlot,
  }) {
    return ProfileSelfPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      isPrimary: isPrimary ?? this.isPrimary,
      backendSlot: backendSlot ?? this.backendSlot,
    );
  }
}

/// Data model for the self profile (editable view)
class ProfileSelfData {
  final String id;
  final String name;
  final int age;
  final String? location;
  final List<ProfileSelfPhoto> photos;
  final String aboutMe;
  final List<String> interests;
  final List<String> personalityTraits;
  final String conversationStyleTitle;
  final String conversationStyleDescription;

  const ProfileSelfData({
    required this.id,
    required this.name,
    required this.age,
    this.location,
    this.photos = const [],
    required this.aboutMe,
    this.interests = const [],
    this.personalityTraits = const [],
    required this.conversationStyleTitle,
    required this.conversationStyleDescription,
  });

  ProfileSelfData copyWith({
    String? id,
    String? name,
    int? age,
    String? Function()? location,
    List<ProfileSelfPhoto>? photos,
    String? aboutMe,
    List<String>? interests,
    List<String>? personalityTraits,
    String? conversationStyleTitle,
    String? conversationStyleDescription,
  }) {
    return ProfileSelfData(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location != null ? location() : this.location,
      photos: photos ?? this.photos,
      aboutMe: aboutMe ?? this.aboutMe,
      interests: interests ?? this.interests,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      conversationStyleTitle:
          conversationStyleTitle ?? this.conversationStyleTitle,
      conversationStyleDescription:
          conversationStyleDescription ?? this.conversationStyleDescription,
    );
  }

  /// Returns the primary photo, or the first photo if no primary is set
  ProfileSelfPhoto? get primaryPhoto {
    if (photos.isEmpty) return null;
    return photos.firstWhere(
      (photo) => photo.isPrimary,
      orElse: () => photos.first,
    );
  }

  /// Returns secondary photos (non-primary)
  List<ProfileSelfPhoto> get secondaryPhotos {
    if (photos.isEmpty) return [];
    final primary = primaryPhoto!;
    return photos.where((photo) => photo.id != primary.id).toList();
  }
}
