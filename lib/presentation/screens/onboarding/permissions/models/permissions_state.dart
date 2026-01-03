class PermissionsState {
  final bool locationGranted;
  final bool notificationsGranted;
  final bool photoLibraryGranted;
  final bool cameraGranted;

  const PermissionsState({
    this.locationGranted = false,
    this.notificationsGranted = false,
    this.photoLibraryGranted = false,
    this.cameraGranted = false,
  });

  PermissionsState copyWith({
    bool? locationGranted,
    bool? notificationsGranted,
    bool? photoLibraryGranted,
    bool? cameraGranted,
  }) {
    return PermissionsState(
      locationGranted: locationGranted ?? this.locationGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      photoLibraryGranted: photoLibraryGranted ?? this.photoLibraryGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsState &&
          runtimeType == other.runtimeType &&
          locationGranted == other.locationGranted &&
          notificationsGranted == other.notificationsGranted &&
          photoLibraryGranted == other.photoLibraryGranted &&
          cameraGranted == other.cameraGranted;

  @override
  int get hashCode =>
      locationGranted.hashCode ^
      notificationsGranted.hashCode ^
      photoLibraryGranted.hashCode ^
      cameraGranted.hashCode;
}
