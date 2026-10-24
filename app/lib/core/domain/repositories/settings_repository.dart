/// Interface only — see architecture/repository_pattern.md. Implementation
/// wraps `shared_preferences` and lives in data/.
///
/// Backs `AppSettings.selectedAlbumId` per sdd/core/data/data-model.md.
/// Named "last used album" here to match sdd/core/domain/domain-rules.md
/// DR-7's terminology (Initial Album Focus) rather than the raw field name.
abstract class SettingsRepository {
  /// Null if no capture has ever completed (fresh install).
  Future<String?> getLastUsedAlbum();

  /// Called only after a successful capture — see DR-7/DR-15. Never called
  /// on mere carousel selection/browsing.
  Future<void> setLastUsedAlbum(String albumName);
}
