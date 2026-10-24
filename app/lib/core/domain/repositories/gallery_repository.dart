import '../entities/album.dart';

/// Interface only — see architecture/repository_pattern.md. Implementation
/// wraps `photo_manager` and lives in data/.
abstract class GalleryRepository {
  /// Saves [filePath] into the device gallery album named [albumName],
  /// creating the MediaStore album on first write (Pending Album state
  /// machine — see sdd/core/domain/domain-rules.md DR-9).
  Future<void> saveImageIntoAlbum({
    required String filePath,
    required String albumName,
  });

  /// User-created, non-system albums only (sdd DR-2). Returns every album
  /// the app recognizes, visible or hidden (DR-14) — callers filter by
  /// [Album.isVisibleInLoop] for carousel-facing views. Never returns two
  /// entries for the same album name (deduped at the data layer).
  Future<List<Album>> fetchAlbums();

  /// Show/Hide toggle — see sdd/core/domain/domain-rules.md DR-11/DR-14.
  /// Never affects the underlying device album or its photos.
  Future<void> setAlbumVisibility({
    required String albumName,
    required bool isVisible,
  });
}
