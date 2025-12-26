class PermissionsState {
  final bool locationGranted;
  final bool notificationsGranted;

  const PermissionsState({
    this.locationGranted = false,
    this.notificationsGranted = false,
  });

  PermissionsState copyWith({
    bool? locationGranted,
    bool? notificationsGranted,
  }) {
    return PermissionsState(
      locationGranted: locationGranted ?? this.locationGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsState &&
          runtimeType == other.runtimeType &&
          locationGranted == other.locationGranted &&
          notificationsGranted == other.notificationsGranted;

  @override
  int get hashCode => locationGranted.hashCode ^ notificationsGranted.hashCode;
}
