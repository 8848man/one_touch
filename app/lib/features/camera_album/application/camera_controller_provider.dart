import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/repository_providers.dart';

part 'camera_controller_provider.g.dart';

/// Owns the CameraController lifecycle. Disposed automatically when no
/// widget is watching (autoDispose, the codegen default) — see
/// architecture/riverpod_mvvm.md.
@riverpod
class CameraControllerNotifier extends _$CameraControllerNotifier {
  @override
  Future<CameraController> build() async {
    final controller = await ref.read(cameraRepositoryProvider).initialize();
    ref.onDispose(() => ref.read(cameraRepositoryProvider).dispose(controller));
    return controller;
  }
}
