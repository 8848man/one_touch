// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_and_save_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$captureAndSaveNotifierHash() =>
    r'10d38e3c2ba83951e4083ce17ea40eaa36b3eafe';

/// Orchestrates capture -> save -> album-list refresh. Exposes AsyncValue
/// so the UI can disable the shutter while `isLoading` — plus an explicit
/// `_busy` lock, since the device spike found a rapid double-tap throws an
/// unhandled CameraException even before the UI can repaint a disabled state.
///
/// Copied from [CaptureAndSaveNotifier].
@ProviderFor(CaptureAndSaveNotifier)
final captureAndSaveNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CaptureAndSaveNotifier, void>.internal(
  CaptureAndSaveNotifier.new,
  name: r'captureAndSaveNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$captureAndSaveNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CaptureAndSaveNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
