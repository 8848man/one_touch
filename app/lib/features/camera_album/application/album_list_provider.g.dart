// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$albumListHash() => r'e8e675def2ae53d5dc344387905a23793c309524';

/// All albums the app recognizes, visible or hidden — sdd DR-14 (Album
/// Management shows all albums). The carousel-facing view is
/// [visibleAlbums], not this provider directly.
///
/// Copied from [albumList].
@ProviderFor(albumList)
final albumListProvider = AutoDisposeFutureProvider<List<Album>>.internal(
  albumList,
  name: r'albumListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$albumListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlbumListRef = AutoDisposeFutureProviderRef<List<Album>>;
String _$visibleAlbumsHash() => r'cc8c74b0e853f7e8ad38fdeac95dcff206b615ff';

/// Carousel-facing view: visible albums only (DR-11). Never a hidden album
/// reaches the carousel or the shutter's save target through this provider.
///
/// Copied from [visibleAlbums].
@ProviderFor(visibleAlbums)
final visibleAlbumsProvider = AutoDisposeFutureProvider<List<Album>>.internal(
  visibleAlbums,
  name: r'visibleAlbumsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleAlbumsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisibleAlbumsRef = AutoDisposeFutureProviderRef<List<Album>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
