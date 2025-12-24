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

  static const Object _noChange = Object();

  BasicsFormData copyWith({
    Object? firstName = _noChange,
    Object? dateOfBirth = _noChange,
    Object? gender = _noChange,
    Object? photoUrl = _noChange,
    int? currentStep,
  }) {
    return BasicsFormData(
      firstName:
          firstName == _noChange ? this.firstName : firstName as String?,
      dateOfBirth: dateOfBirth == _noChange
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      gender: gender == _noChange ? this.gender : gender as String?,
      photoUrl: photoUrl == _noChange ? this.photoUrl : photoUrl as String?,
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
