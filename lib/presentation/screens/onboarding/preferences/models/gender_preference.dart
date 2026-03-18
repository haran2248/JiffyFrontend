enum GenderPreference {
  women('Woman'),
  men('Man'),
  nonBinary('Non-binary'),
  everyone('Everyone');

  final String label;
  const GenderPreference(this.label);
}
