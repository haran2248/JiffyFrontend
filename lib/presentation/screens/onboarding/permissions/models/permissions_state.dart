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
}
