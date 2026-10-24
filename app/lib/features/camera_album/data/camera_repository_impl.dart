import 'package:camera/camera.dart';

import '../../../core/domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  @override
  Future<CameraController> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('no_camera', 'No camera available on this device.');
    }
    // enableAudio: false — required per the device-validation spike, which
    // found the plugin requests microphone permission by default otherwise,
    // despite this app never recording video.
    final controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller.initialize();
    return controller;
  }

  @override
  Future<XFile> takePicture(CameraController controller) {
    return controller.takePicture();
  }

  @override
  Future<void> dispose(CameraController controller) {
    return controller.dispose();
  }
}
