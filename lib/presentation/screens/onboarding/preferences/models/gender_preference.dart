enum GenderPreference {
  women('Women'),
  men('Men'),
  nonBinary('Non-binary'),
  everyone('Everyone');

  final String label;
  const GenderPreference(this.label);
}
