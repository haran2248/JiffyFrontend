// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_setup_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileSetupViewModel)
const profileSetupViewModelProvider = ProfileSetupViewModelProvider._();

final class ProfileSetupViewModelProvider
    extends $NotifierProvider<ProfileSetupViewModel, ProfileSetupFormData> {
  const ProfileSetupViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileSetupViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileSetupViewModelHash();

  @$internal
  @override
  ProfileSetupViewModel create() => ProfileSetupViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileSetupFormData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileSetupFormData>(value),
    );
  }
}

String _$profileSetupViewModelHash() =>
    r'cbb9fc5c772d613e2c58f3631ef1a6fa17a22840';

abstract class _$ProfileSetupViewModel extends $Notifier<ProfileSetupFormData> {
  ProfileSetupFormData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileSetupFormData, ProfileSetupFormData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileSetupFormData, ProfileSetupFormData>,
        ProfileSetupFormData,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
