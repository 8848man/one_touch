// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_album_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialAlbumFocusHash() => r'ac040788b83fb8e42416fa0c4f6dc317fc45f6c9';

/// Initial Album Focus (sdd DR-7) — overridden at app startup in main.dart
/// with the persisted last-used album, if one exists. Kept as a separate
/// provider (rather than reading SettingsRepository directly in
/// SelectedAlbumNotifier.build()) so the notifier's build() stays
/// synchronous and every existing `ref.watch(selectedAlbumNotifierProvider)`
/// call site continues to receive a plain String, not an AsyncValue.
///
/// Copied from [initialAlbumFocus].
@ProviderFor(initialAlbumFocus)
final initialAlbumFocusProvider = AutoDisposeProvider<String>.internal(
  initialAlbumFocus,
  name: r'initialAlbumFocusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialAlbumFocusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialAlbumFocusRef = AutoDisposeProviderRef<String>;
String _$selectedAlbumNotifierHash() =>
    r'c198e9c379be50ca7c5ac65f63e1ec26c42baaf2';

/// See also [SelectedAlbumNotifier].
@ProviderFor(SelectedAlbumNotifier)
final selectedAlbumNotifierProvider =
    AutoDisposeNotifierProvider<SelectedAlbumNotifier, String>.internal(
  SelectedAlbumNotifier.new,
  name: r'selectedAlbumNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedAlbumNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedAlbumNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
