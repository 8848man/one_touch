import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

/// Thin wrapper over the camera plugin (ported from the MVP camera_repository_impl.dart).
class CameraService {
  Future<List<CameraDescription>> cameras() => availableCameras();

  Future<CameraController> open(CameraDescription description, {required bool enableAudio}) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      // Audio only when the microphone was granted; otherwise videos are silent.
      enableAudio: enableAudio,
    );
    await controller.initialize();
    return controller;
  }
}

class PermissionSnapshot {
  const PermissionSnapshot({required this.camera, required this.media, required this.microphone});

  final bool camera;
  final bool media;
  final bool microphone;

  /// Camera + gallery are required; microphone only adds audio to videos.
  bool get ready => camera && media;

  PermissionSnapshot copyWith({bool? microphone}) =>
      PermissionSnapshot(camera: camera, media: media, microphone: microphone ?? this.microphone);
}

/// sdd_v2 screens.md §0 — one in-app explanation, then only the system
/// dialogs that are needed: camera + photos up front, microphone the first
/// time video mode is chosen. Android cannot merge permission groups into a
/// single system dialog.
class PermissionService {
  static const _mediaOption = PermissionRequestOption(
    androidPermission: AndroidPermission(type: RequestType.common, mediaLocation: false),
  );

  /// Current state without showing any dialog.
  Future<PermissionSnapshot> status() async {
    final camera = await Permission.camera.status;
    final media = await PhotoManager.getPermissionState(requestOption: _mediaOption);
    final microphone = await Permission.microphone.status;
    return PermissionSnapshot(camera: camera.isGranted, media: media.hasAccess, microphone: microphone.isGranted);
  }

  /// Camera + photos/videos, asked back to back.
  Future<PermissionSnapshot> requestEssentials() async {
    final camera = await Permission.camera.request();
    final media = await PhotoManager.requestPermissionExtend(requestOption: _mediaOption);
    final microphone = await Permission.microphone.status;
    return PermissionSnapshot(camera: camera.isGranted, media: media.hasAccess, microphone: microphone.isGranted);
  }

  Future<bool> requestMicrophone() async => (await Permission.microphone.request()).isGranted;

  Future<bool> openSettings() => openAppSettings();
}
