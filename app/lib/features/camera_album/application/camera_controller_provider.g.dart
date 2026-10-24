// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cameraControllerNotifierHash() =>
    r'f6aed17da69699277fe08a55c0e3ceecfb5f33e6';

/// Owns the CameraController lifecycle. Disposed automatically when no
/// widget is watching (autoDispose, the codegen default) — see
/// architecture/riverpod_mvvm.md.
///
/// Copied from [CameraControllerNotifier].
@ProviderFor(CameraControllerNotifier)
final cameraControllerNotifierProvider = AutoDisposeAsyncNotifierProvider<
    CameraControllerNotifier, CameraController>.internal(
  CameraControllerNotifier.new,
  name: r'cameraControllerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraControllerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CameraControllerNotifier = AutoDisposeAsyncNotifier<CameraController>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
