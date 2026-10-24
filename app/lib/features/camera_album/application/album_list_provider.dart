import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/repository_providers.dart';
import '../../../core/domain/entities/album.dart';

part 'album_list_provider.g.dart';

/// All albums the app recognizes, visible or hidden — sdd DR-14 (Album
/// Management shows all albums). The carousel-facing view is
/// [visibleAlbums], not this provider directly.
@riverpod
Future<List<Album>> albumList(AlbumListRef ref) async {
  final albums = await ref.read(galleryRepositoryProvider).fetchAlbums();
  // TEMP DIAGNOSTIC — pipeline audit, stage 3. Print-only.
  // ignore: avoid_print
  print('[PIPELINE_AUDIT] === STAGE 3: albumListProvider output '
      '(${albums.length} entries): ${albums.map((a) => a.name).toList()} ===');
  return albums;
}

/// Carousel-facing view: visible albums only (DR-11). Never a hidden album
/// reaches the carousel or the shutter's save target through this provider.
@riverpod
Future<List<Album>> visibleAlbums(VisibleAlbumsRef ref) async {
  final albums = await ref.watch(albumListProvider.future);
  final visible = albums.where((a) => a.isVisibleInLoop).toList();
  // TEMP DIAGNOSTIC — pipeline audit, stage 4. Print-only.
  // ignore: avoid_print
  print('[PIPELINE_AUDIT] === STAGE 4: visibleAlbumsProvider output '
      '(${visible.length} entries): ${visible.map((a) => a.name).toList()} ===');
  return visible;
}
