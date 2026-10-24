import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/repository_providers.dart';
import '../../../core/domain/entities/album.dart';
import 'album_list_provider.dart';
import 'selected_album_provider.dart';

part 'album_management_provider.g.dart';

/// Orchestrates Album Management mutations (show/hide, create) — see
/// sdd/feature/album/manage-album.md and sdd/feature/album/create-album.md.
/// Widgets call this ViewModel-equivalent notifier, never the repository
/// directly (architecture/riverpod_mvvm.md).
@riverpod
class AlbumManagementNotifier extends _$AlbumManagementNotifier {
  @override
  FutureOr<void> build() {}

  /// Show/Hide toggle (DR-11/DR-14). If the currently-selected album is
  /// hidden, immediately reselects another visible album (DR-12) — preferring
  /// the persisted last-used album if it's still visible, otherwise the first
  /// remaining visible album. If none remain visible, selection is left
  /// as-is and the carousel enters the empty-loop state (DR-13).
  Future<void> toggleVisibility(Album album, bool isVisible) async {
    await ref.read(galleryRepositoryProvider).setAlbumVisibility(
          albumName: album.name,
          isVisible: isVisible,
        );

    if (!isVisible) {
      final selected = ref.read(selectedAlbumNotifierProvider);
      if (selected == album.name) {
        final all = await ref.read(galleryRepositoryProvider).fetchAlbums();
        final stillVisible =
            all.where((a) => a.isVisibleInLoop && a.name != album.name).toList();
        if (stillVisible.isNotEmpty) {
          final lastUsed = await ref.read(settingsRepositoryProvider).getLastUsedAlbum();
          final resolved = stillVisible.firstWhere(
            (a) => a.name == lastUsed,
            orElse: () => stillVisible.first,
          );
          ref.read(selectedAlbumNotifierProvider.notifier).select(resolved.name);
        }
        // else: zero visible albums remain — DR-13. No reselection target
        // exists; visibleAlbumsProvider will be empty and the carousel/
        // shutter already handle that state (see album_reel.dart, AC4).
      }
    }

    ref.invalidate(albumListProvider);
    ref.invalidate(visibleAlbumsProvider);
  }

  /// Create Album (DR-4 duplicate check, DR-15 lifecycle). Returns a
  /// user-facing error message on rejection, null on success. On success,
  /// the new album immediately becomes the in-session selection via the
  /// existing Pending Album mechanism (DR-9) — there is no "create empty
  /// album" API on Android, so no repository call happens here; the album
  /// materializes on first capture (see capture_and_save_provider.dart).
  Future<String?> createAlbum(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Album name cannot be empty.';
    }

    final current = await ref.read(galleryRepositoryProvider).fetchAlbums();
    final currentSelection = ref.read(selectedAlbumNotifierProvider);
    final isDuplicate =
        current.any((a) => a.name == trimmed) || trimmed == currentSelection;
    if (isDuplicate) {
      // Exact copy per sdd/feature/album/create-album.md DR-4.
      return '동일한 이름의 앨범이 이미 존재합니다.';
    }

    ref.read(selectedAlbumNotifierProvider.notifier).select(trimmed);
    ref.invalidate(albumListProvider);
    ref.invalidate(visibleAlbumsProvider);
    return null;
  }
}
