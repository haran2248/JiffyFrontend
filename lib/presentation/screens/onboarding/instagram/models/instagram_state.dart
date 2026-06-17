class InstagramState {
  final String handle;
  final String followersCount;
  final bool isSaving;
  final String? error;
  final bool isWaitlisted;

  InstagramState({
    this.handle = '',
    this.followersCount = '',
    this.isSaving = false,
    this.error,
    this.isWaitlisted = false,
  });

  InstagramState copyWith({
    String? handle,
    String? followersCount,
    bool? isSaving,
    String? error,
    bool? isWaitlisted,
  }) {
    return InstagramState(
      handle: handle ?? this.handle,
      followersCount: followersCount ?? this.followersCount,
      isSaving: isSaving ?? this.isSaving,
      error: error, // intentionally allow nulling out error
      isWaitlisted: isWaitlisted ?? this.isWaitlisted,
    );
  }

  bool get isValid => handle.isNotEmpty && int.tryParse(followersCount) != null && int.parse(followersCount) >= 0;
}
