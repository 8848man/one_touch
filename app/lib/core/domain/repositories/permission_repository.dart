/// Interface only — see architecture/repository_pattern.md. Implementation
/// wraps `permission_handler` and lives in data/.
abstract class PermissionRepository {
  /// Requests camera + photo-library access. Returns true only if both
  /// are granted (sdd/feature/onboarding/first-run-flow.md: camera first,
  /// then photo access).
  Future<bool> requestCameraAndPhotoAccess();
}
