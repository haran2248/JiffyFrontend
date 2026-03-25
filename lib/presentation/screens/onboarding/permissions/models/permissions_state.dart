class PermissionsState {
  final bool locationGranted;
  final bool notificationsGranted;
  final bool photoLibraryGranted;
  final bool cameraGranted;
  final bool isWaitlisted;

  const PermissionsState({
    this.locationGranted = false,
    this.notificationsGranted = false,
    this.photoLibraryGranted = false,
    this.cameraGranted = false,
    this.isWaitlisted = false,
  });

  PermissionsState copyWith({
    bool? locationGranted,
    bool? notificationsGranted,
    bool? photoLibraryGranted,
    bool? cameraGranted,
    bool? isWaitlisted,
  }) {
    return PermissionsState(
      locationGranted: locationGranted ?? this.locationGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      photoLibraryGranted: photoLibraryGranted ?? this.photoLibraryGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      isWaitlisted: isWaitlisted ?? this.isWaitlisted,
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
          cameraGranted == other.cameraGranted &&
          isWaitlisted == other.isWaitlisted;

  @override
  int get hashCode =>
      locationGranted.hashCode ^
      notificationsGranted.hashCode ^
      photoLibraryGranted.hashCode ^
      cameraGranted.hashCode ^
      isWaitlisted.hashCode;
}
