class BasicDetails {
  final String preferredGender;

  BasicDetails({required this.preferredGender});

  Map<String, dynamic> toJson() {
    return {
      'preferredGender': preferredGender,
    };
  }
}
