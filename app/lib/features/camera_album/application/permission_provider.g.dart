// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$permissionStatusNotifierHash() =>
    r'5a1573f292a9fc001b6db146ebe20449607c88a0';

/// Resolves to true once camera+photo access is granted. UI gates on
/// this per architecture/riverpod_mvvm.md ("fail gracefully with UI state").
///
/// Copied from [PermissionStatusNotifier].
@ProviderFor(PermissionStatusNotifier)
final permissionStatusNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PermissionStatusNotifier, bool>.internal(
  PermissionStatusNotifier.new,
  name: r'permissionStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PermissionStatusNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
