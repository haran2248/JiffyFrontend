class BasicsFormData {
  final String? firstName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? photoUrl;
  final String? college;
  final String? work;
  final int currentStep;

  const BasicsFormData({
    this.firstName,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.college,
    this.work,
    this.currentStep = 1,
  });

  BasicsFormData copyWith({
    String? firstName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    String? college,
    String? work,
    int? currentStep,
  }) {
    return BasicsFormData(
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      college: college ?? this.college,
      work: work ?? this.work,
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
