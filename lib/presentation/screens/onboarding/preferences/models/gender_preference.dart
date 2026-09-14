enum GenderPreference {
  women('Women', 'Woman'),
  men('Men', 'Man'),
  nonBinary('Non-binary', 'Non-binary'),
  everyone('Everyone', 'Everyone');

  final String label;
  final String backendValue;

  const GenderPreference(this.label, this.backendValue);

  /// Find GenderPreference by backend value or label
  static GenderPreference? fromValue(String? value) {
    if (value == null) return null;
    return GenderPreference.values.cast<GenderPreference?>().firstWhere(
          (g) =>
              g?.backendValue.toLowerCase() == value.toLowerCase() ||
              g?.label.toLowerCase() == value.toLowerCase(),
          orElse: () => null,
        );
  }
}
