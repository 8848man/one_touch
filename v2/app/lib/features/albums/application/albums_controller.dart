import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album.dart';
import '../../../core/domain/album_rules.dart';
import '../../../core/data/media_gallery.dart';
import '../../../core/providers.dart';
import '../../settings/application/settings_providers.dart';
import 'media_providers.dart';

/// How a rename ended (V7).
enum RenameResult {
  /// App name and device folder both changed.
  renamed,

  /// Only the app name changed: this Android version cannot move the files.
  nameOnly,

  /// The user declined the system confirmation; nothing changed.
  denied,
}

class AlbumsState {
  const AlbumsState({required this.albums, required this.selectedId});

  /// Every app album, sorted by [Album.sortOrder] (V2, V12).
  final List<Album> albums;

  /// Currently selected save target; null when no album is visible (V10).
  final String? selectedId;

  List<Album> get visible => [for (final a in albums) if (a.isVisible) a];

  Album? get selected {
    for (final a in albums) {
      if (a.id == selectedId) return a;
    }
    return null;
  }
}

/// Album lifecycle — sdd_v2/domain-rules.md V1–V13.
class AlbumsNotifier extends Notifier<AlbumsState> {
  @override
  AlbumsState build() {
    final albums = _sorted(ref.read(albumStoreProvider).load());
    return AlbumsState(
      albums: albums,
      selectedId: resolveSelection(albums, preferredId: ref.read(appPrefsProvider).selectedAlbumId),
    );
  }

  static List<Album> _sorted(Iterable<Album> albums) =>
      [...albums]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  Future<void> _commit(List<Album> albums, {String? preferredId}) async {
    final sorted = _sorted(albums);
    state = AlbumsState(
      albums: sorted,
      selectedId: resolveSelection(sorted, preferredId: preferredId ?? state.selectedId),
    );
    await ref.read(albumStoreProvider).save(sorted);
  }

  /// V13 — free users may keep at most [kFreeActiveAlbumLimit] albums on.
  /// Creating an album also switches one on, so it uses the same check.
  bool get canActivateMore =>
      canActivateAlbum(activeCount: state.visible.length, premium: ref.read(premiumProvider));

  String? validateName(String name, {String? exceptId}) =>
      validateAlbumName(name, state.albums, exceptId: exceptId);

  /// Creates an album, appends it and selects it (V5). Throws [ArgumentError]
  /// with a user-facing message when the name is invalid.
  Future<Album> create(String rawName) async {
    final name = normalizeAlbumName(rawName);
    final error = validateName(name);
    if (error != null) throw ArgumentError(error);
    final now = DateTime.now();
    final nextOrder = state.albums.isEmpty ? 0 : state.albums.map((a) => a.sortOrder).reduce(math.max) + 1;
    final album = Album(
      id: _newId(now),
      folderName: uniqueFolderName(name, state.albums),
      displayName: name,
      isVisible: true,
      sortOrder: nextOrder,
      createdAt: now,
    );
    await _commit([...state.albums, album], preferredId: album.id);
    // V18 — a new album that reuses a dismissed folder brings that folder back.
    final prefs = ref.read(appPrefsProvider);
    final dismissed = prefs.dismissedFolders;
    if (dismissed.remove(album.folderName)) await prefs.setDismissedFolders(dismissed);
    return album;
  }

  bool _syncing = false;

  /// V15/V16 — adds gallery folders the app has not seen yet (hidden). On the
  /// very first import with no albums at all, the newest few are switched on.
  Future<void> importFolders(List<GalleryFolder> folders) async {
    final prefs = ref.read(appPrefsProvider);
    final firstRun = !prefs.galleryImported && state.albums.isEmpty;
    final merged = mergeGalleryFolders(
      state.albums,
      folders,
      now: DateTime.now(),
      dismissed: prefs.dismissedFolders,
      activateRecent: firstRun ? kFreeActiveAlbumLimit : 0,
    );
    if (!identical(merged, state.albums)) await _commit(merged);
    if (!prefs.galleryImported) await prefs.setGalleryImported();
  }

  /// Reads the device gallery and imports new folders. Safe to call often.
  Future<void> syncWithGallery() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await importFolders(await ref.read(mediaGalleryProvider).scanFolders());
    } finally {
      _syncing = false;
    }
  }

  /// Clock-based ids can collide on Windows, where DateTime.now() has coarse
  /// resolution — bump until the id is unused.
  String _newId(DateTime now) {
    final taken = {for (final a in state.albums) a.id};
    var n = now.microsecondsSinceEpoch;
    while (taken.contains('a$n')) {
      n++;
    }
    return 'a$n';
  }

  void select(String id) {
    if (state.visible.any((a) => a.id == id) && id != state.selectedId) {
      state = AlbumsState(albums: state.albums, selectedId: id);
    }
  }

  /// V3/V9/V10/V13 — hiding the selected album reselects another visible one.
  /// Returns false (and changes nothing) when switching on would exceed the
  /// free active-album limit.
  Future<bool> setVisible(String id, bool visible) async {
    if (visible && !canActivateMore) return false;
    await _commit([for (final a in state.albums) a.id == id ? a.copyWith(isVisible: visible) : a]);
    return true;
  }

  /// V7 — renames the album and its device folder. Android has no folder
  /// rename, so every photo/video is moved to a sibling folder with the new
  /// name (one system confirmation on Android 11+). Gallery sync is paused
  /// meanwhile so the half-moved folder is not imported as a new album.
  Future<RenameResult> rename(String id, String rawName) async {
    final name = normalizeAlbumName(rawName);
    final error = validateName(name, exceptId: id);
    if (error != null) throw ArgumentError(error);
    final album = state.albums.firstWhere((a) => a.id == id);
    final others = [for (final a in state.albums) if (a.id != id) a];
    final folder = uniqueFolderName(name, others);
    if (folder == album.folderName) {
      await _replace(album.copyWith(displayName: name));
      return RenameResult.renamed;
    }

    _syncing = true;
    try {
      final target = MediaGallery.siblingPath(album.savePath, folder);
      final outcome = await ref.read(mediaGalleryProvider).moveFolder(album.folderName, target);
      switch (outcome.status) {
        case MoveStatus.moved:
        case MoveStatus.empty:
          await _replace(album.copyWith(
            displayName: name,
            folderName: folder,
            relativePath: album.relativePath == null ? null : target,
          ));
          refreshMedia(ref);
          return RenameResult.renamed;
        case MoveStatus.unsupported:
          await _replace(album.copyWith(displayName: name));
          return RenameResult.nameOnly;
        case MoveStatus.denied:
          return RenameResult.denied;
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> _replace(Album album) =>
      _commit([for (final a in state.albums) a.id == album.id ? album : a]);

  /// V8/V18 — removes the app record only; photos stay in the device gallery.
  /// Deleted imported folders are remembered so the next sync skips them.
  Future<void> delete(String id) async {
    Album? removed;
    for (final a in state.albums) {
      if (a.id == id) removed = a;
    }
    await _commit([for (final a in state.albums) if (a.id != id) a]);
    if (removed != null && removed.isImported) {
      final prefs = ref.read(appPrefsProvider);
      await prefs.setDismissedFolders({...prefs.dismissedFolders, removed.folderName});
    }
  }

  /// V12 — indices follow [ReorderableListView.onReorder] semantics.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state.albums];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    await _commit([for (var i = 0; i < list.length; i++) list[i].copyWith(sortOrder: i)]);
  }

  /// V11 — called after a successful capture only.
  Future<void> markUsed(String id) async {
    final now = DateTime.now();
    await _commit([for (final a in state.albums) a.id == id ? a.copyWith(lastUsedAt: now) : a]);
    await ref.read(appPrefsProvider).setSelectedAlbumId(id);
  }
}

final albumsProvider = NotifierProvider<AlbumsNotifier, AlbumsState>(AlbumsNotifier.new);
