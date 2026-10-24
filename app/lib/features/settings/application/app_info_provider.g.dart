// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appInfoHash() => r'0ba9aeebe0beb890e9a9a2e10e878741c8670381';

/// Backs the App Version item in Settings — sdd/feature/settings/overview.md.
/// Thin, presentation-adjacent provider only; no domain/data layer of its
/// own, per architecture/feature_guidelines.md's `settings` section.
///
/// Copied from [appInfo].
@ProviderFor(appInfo)
final appInfoProvider = AutoDisposeFutureProvider<PackageInfo>.internal(
  appInfo,
  name: r'appInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppInfoRef = AutoDisposeFutureProviderRef<PackageInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
