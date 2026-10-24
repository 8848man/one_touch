// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$albumManagementNotifierHash() =>
    r'3a08a190a0d8d472adfd05ebf81e8285d79fe843';

/// Orchestrates Album Management mutations (show/hide, create) — see
/// sdd/feature/album/manage-album.md and sdd/feature/album/create-album.md.
/// Widgets call this ViewModel-equivalent notifier, never the repository
/// directly (architecture/riverpod_mvvm.md).
///
/// Copied from [AlbumManagementNotifier].
@ProviderFor(AlbumManagementNotifier)
final albumManagementNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AlbumManagementNotifier, void>.internal(
  AlbumManagementNotifier.new,
  name: r'albumManagementNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$albumManagementNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlbumManagementNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
