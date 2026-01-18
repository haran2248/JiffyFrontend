class BasicDetails {
  final String? name;
  final String? gender;
  final String? preferredGender;
  final DateTime? birthDate;
  final String? photoUrl;

  BasicDetails({
    this.name,
    this.gender,
    this.preferredGender,
    this.birthDate,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name;
    }
    if (gender != null) {
      data['gender'] = gender;
    }
    if (preferredGender != null) {
      data['preferredGender'] = preferredGender;
    }
    if (birthDate != null) {
      // Format as yyyy-MM-dd to match backend @JsonFormat
      final year = birthDate!.year.toString().padLeft(4, '0');
      final month = birthDate!.month.toString().padLeft(2, '0');
      final day = birthDate!.day.toString().padLeft(2, '0');
      data['birthDate'] = '$year-$month-$day';
    }
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }

    return data;
  }
}
