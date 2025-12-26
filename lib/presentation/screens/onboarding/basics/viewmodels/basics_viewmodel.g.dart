// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basics_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BasicsViewModel)
const basicsViewModelProvider = BasicsViewModelProvider._();

final class BasicsViewModelProvider
    extends $NotifierProvider<BasicsViewModel, BasicsFormData> {
  const BasicsViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'basicsViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$basicsViewModelHash();

  @$internal
  @override
  BasicsViewModel create() => BasicsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BasicsFormData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BasicsFormData>(value),
    );
  }
}

String _$basicsViewModelHash() => r'deba523dc5a2b5c8e8ade654990fb9c104d8649c';

abstract class _$BasicsViewModel extends $Notifier<BasicsFormData> {
  BasicsFormData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BasicsFormData, BasicsFormData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BasicsFormData, BasicsFormData>,
        BasicsFormData,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
