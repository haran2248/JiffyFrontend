class PermissionsState {
  final bool locationGranted;
  final bool notificationsGranted;
  final bool photoLibraryGranted;
  final bool cameraGranted;
  final bool isWaitlisted;
  /// Non-null when a permission was denied; contains the message to show.
  final String? deniedMessage;
  /// True when iOS has permanently denied the permission (system dialog won't appear again).
  final bool isPermanentlyDenied;

  const PermissionsState({
    this.locationGranted = false,
    this.notificationsGranted = false,
    this.photoLibraryGranted = false,
    this.cameraGranted = false,
    this.isWaitlisted = false,
    this.deniedMessage,
    this.isPermanentlyDenied = false,
  });

  PermissionsState copyWith({
    bool? locationGranted,
    bool? notificationsGranted,
    bool? photoLibraryGranted,
    bool? cameraGranted,
    bool? isWaitlisted,
    String? deniedMessage,
    bool clearDeniedMessage = false,
    bool? isPermanentlyDenied,
  }) {
    return PermissionsState(
      locationGranted: locationGranted ?? this.locationGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      photoLibraryGranted: photoLibraryGranted ?? this.photoLibraryGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      isWaitlisted: isWaitlisted ?? this.isWaitlisted,
      deniedMessage: clearDeniedMessage
          ? null
          : (deniedMessage ?? this.deniedMessage),
      isPermanentlyDenied:
          isPermanentlyDenied ?? this.isPermanentlyDenied,
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
          isWaitlisted == other.isWaitlisted &&
          deniedMessage == other.deniedMessage &&
          isPermanentlyDenied == other.isPermanentlyDenied;

  @override
  int get hashCode =>
      locationGranted.hashCode ^
      notificationsGranted.hashCode ^
      photoLibraryGranted.hashCode ^
      cameraGranted.hashCode ^
      isWaitlisted.hashCode ^
      deniedMessage.hashCode ^
      isPermanentlyDenied.hashCode;
}
