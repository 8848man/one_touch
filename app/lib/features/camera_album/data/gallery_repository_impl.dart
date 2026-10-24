import 'dart:developer' as developer;
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/entities/album.dart';
import '../../../core/domain/repositories/gallery_repository.dart';

/// Persisted set of hidden album names (DR-11/DR-14). App-tracked only —
/// `photo_manager`/MediaStore has no native "visible in this app's loop"
/// concept, per sdd/core/data/data-model.md's `Album.isVisibleInLoop`.
const _hiddenAlbumsKey = 'hidden_albums';

/// Android has no OS-level flag distinguishing user-created albums from
/// app-generated ones (see sdd/core/domain/domain-rules.md DR-10) — this
/// denylist is the app-maintained mechanism DR-2 requires. Named entries match
/// sdd/core/domain/domain-rules.md DR-2 exactly. 'Camera' is intentionally
/// NOT denylisted — DR-1 names it as an example real album and DR-3/
/// album-definition.md restrict valid save targets to "Camera + user-created
/// albums only", meaning Camera must remain a selectable album, not excluded.
const _systemAlbumDenylist = {
  'Screenshots',
  'Download',
  'WhatsApp Images',
  'WhatsApp Video',
  'KakaoTalk',
  'Messenger',
};

class GalleryRepositoryImpl implements GalleryRepository {
  @override
  Future<void> saveImageIntoAlbum({
    required String filePath,
    required String albumName,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('MVP supports Android only (sdd/infra/platform/platform-support.md).');
    }
    // Validated by the device spike: relativePath both creates the MediaStore
    // bucket on first write and correctly reuses it on repeat writes — no
    // duplicate-folder issue observed (sdd DR-9 Pending Album state machine).
    await PhotoManager.editor.saveImageWithPath(
      filePath,
      title: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      relativePath: 'Pictures/$albumName',
    );
  }

  @override
  Future<List<Album>> fetchAlbums() async {
    // DEBUG: verify permission state before enumerating — an empty/partial
    // result on Android 13+ almost always traces back to READ_MEDIA_IMAGES
    // being denied or limited (see sdd/infra/permissions/permission-handling.md).
    final permissionState = await PhotoManager.requestPermissionExtend();
    developer.log(
      'fetchAlbums: permission=$permissionState '
      '(authorized=${permissionState.isAuth}, hasAccess=${permissionState.hasAccess})',
      name: 'GalleryRepositoryImpl',
    );
    if (!permissionState.hasAccess) {
      developer.log(
        'fetchAlbums: no photo access — returning empty list without querying MediaStore.',
        name: 'GalleryRepositoryImpl',
      );
      return const [];
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
    );
    developer.log(
      'fetchAlbums: raw photo_manager response — ${paths.length} path(s): '
      '${paths.map((p) => p.name).toList()}',
      name: 'GalleryRepositoryImpl',
    );
    // TEMP DIAGNOSTIC — pipeline audit, stage 1: raw AssetPathEntity list.
    // Print-only, no logic change. Remove after investigation.
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] === STAGE 1: raw AssetPathEntity list '
        '(${paths.length} entries, RequestType.image, hasAll=false) ===');
    for (final p in paths) {
      final count = await p.assetCountAsync;
      // ignore: avoid_print
      print('[PIPELINE_AUDIT] id="${p.id}" name="${p.name}" '
          'assetCount=$count isAll=${p.isAll} type=${p.type} '
          'albumType=${p.albumType} lastModified=${p.lastModified} '
          'filterOption=${p.filterOption}');
    }

    // Dedup by name: a defensive guarantee that one physical album never
    // produces more than one Album object, even if a future Android/OEM
    // combination were to return multiple AssetPathEntity rows for the same
    // folder. Runtime investigation (see project history) found no evidence
    // this actually occurs on this device/API level — the real carousel
    // "duplication" symptom was traced to AlbumReel's virtual-index modulo
    // math degenerating when exactly one album exists (fixed separately in
    // album_reel.dart), not to duplicate data here. This dedup stays as a
    // correctness guarantee, not because it was the fix for that bug.
    // TEMP DIAGNOSTIC — pipeline audit, stage 8: before/after denylist filter.
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] === BEFORE denylist filter: '
        '${paths.map((p) => p.name).toList()} ===');
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] denylist contents: $_systemAlbumDenylist');
    final removedByDenylist = paths.where((p) => _systemAlbumDenylist.contains(p.name)).map((p) => p.name).toList();
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] names removed by denylist: $removedByDenylist');

    final countsByName = <String, int>{};
    for (final p in paths) {
      if (_systemAlbumDenylist.contains(p.name)) continue;
      final count = await p.assetCountAsync;
      countsByName.update(p.name, (existing) => existing + count, ifAbsent: () => count);
    }
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] === AFTER denylist filter: '
        '${countsByName.keys.toList()} ===');
    if (countsByName.length != paths.where((p) => !_systemAlbumDenylist.contains(p.name)).length) {
      developer.log(
        'fetchAlbums: deduped ${paths.length} raw path(s) down to ${countsByName.length} '
        'unique album name(s) — duplicate AssetPathEntity rows detected.',
        name: 'GalleryRepositoryImpl',
      );
    }

    final hiddenNames = await _readHiddenAlbumNames();
    final albums = [
      for (final entry in countsByName.entries)
        Album(
          name: entry.key,
          assetCount: entry.value,
          isVisibleInLoop: !hiddenNames.contains(entry.key),
        ),
    ];
    // TEMP DIAGNOSTIC — pipeline audit, stage 2: final Album entities
    // returned by fetchAlbums(). No `id` field exists on Album (name-only
    // identity — see prior audit), so it's omitted rather than fabricated.
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] === STAGE 2: Album entities from fetchAlbums() '
        '(${albums.length} entries) ===');
    for (final a in albums) {
      // ignore: avoid_print
      print('[PIPELINE_AUDIT] name="${a.name}" assetCount=${a.assetCount} '
          'isVisibleInLoop=${a.isVisibleInLoop} isPending=${a.isPending}');
    }

    if (albums.isEmpty) {
      // Not necessarily an error — a fresh device/emulator with zero
      // non-system albums is a valid state. Logged so it's distinguishable
      // from a permission or MediaStore query failure during debugging.
      developer.log(
        'fetchAlbums: 0 albums after denylist filtering (raw count was ${paths.length}). '
        'Verify API level behavior and MediaStore contents if unexpected.',
        name: 'GalleryRepositoryImpl',
      );
    }
    return albums;
  }

  @override
  Future<void> setAlbumVisibility({
    required String albumName,
    required bool isVisible,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hidden = (prefs.getStringList(_hiddenAlbumsKey) ?? const <String>[]).toSet();
    if (isVisible) {
      hidden.remove(albumName);
    } else {
      hidden.add(albumName);
    }
    await prefs.setStringList(_hiddenAlbumsKey, hidden.toList());
  }

  Future<Set<String>> _readHiddenAlbumNames() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_hiddenAlbumsKey) ?? const <String>[]).toSet();
  }
}
