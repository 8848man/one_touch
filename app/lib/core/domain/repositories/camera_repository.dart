import 'package:camera/camera.dart';

/// Interface only — see architecture/repository_pattern.md. Implementation
/// wraps the `camera` plugin and lives in data/.
abstract class CameraRepository {
  Future<CameraController> initialize();
  Future<XFile> takePicture(CameraController controller);
  Future<void> dispose(CameraController controller);
}
