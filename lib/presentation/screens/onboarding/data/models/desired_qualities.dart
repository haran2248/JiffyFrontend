class DesiredQualities {
  final String lookingFor;

  DesiredQualities({required this.lookingFor});

  Map<String, dynamic> toJson() {
    return {
      'lookingFor': lookingFor,
    };
  }
}
