class BasicsFormData {
  final String? firstName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? photoUrl;
  final int currentStep;

  const BasicsFormData({
    this.firstName,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.currentStep = 1,
  });

  BasicsFormData copyWith({
    String? firstName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    int? currentStep,
  }) {
    return BasicsFormData(
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  bool get isValid {
    return firstName != null &&
        firstName!.isNotEmpty &&
        dateOfBirth != null &&
        gender != null &&
        gender!.isNotEmpty;
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}
