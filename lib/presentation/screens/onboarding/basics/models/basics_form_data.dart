class BasicsFormData {
  final String? firstName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? photoUrl;
  final String? college;
  final String? work;
  final int currentStep;
  final bool isSaving;
  final String? error;

  const BasicsFormData({
    this.firstName,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.college,
    this.work,
    this.currentStep = 1,
    this.isSaving = false,
    this.error,
  });

  BasicsFormData copyWith({
    String? firstName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
    String? college,
    String? work,
    int? currentStep,
    bool? isSaving,
    String? Function()? error,
  }) {
    return BasicsFormData(
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      college: college ?? this.college,
      work: work ?? this.work,
      currentStep: currentStep ?? this.currentStep,
      isSaving: isSaving ?? this.isSaving,
      error: error != null ? error() : this.error,
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
