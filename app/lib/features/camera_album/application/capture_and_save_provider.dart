import 'dart:async';

import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/repository_providers.dart';
import 'album_list_provider.dart';
import 'camera_controller_provider.dart';
import 'selected_album_provider.dart';

part 'capture_and_save_provider.g.dart';

/// Orchestrates capture -> save -> album-list refresh. Exposes AsyncValue
/// so the UI can disable the shutter while `isLoading` — plus an explicit
/// `_busy` lock, since the device spike found a rapid double-tap throws an
/// unhandled CameraException even before the UI can repaint a disabled state.
@riverpod
class CaptureAndSaveNotifier extends _$CaptureAndSaveNotifier {
  bool _busy = false;

  @override
  FutureOr<void> build() {}

  Future<void> captureAndSave() async {
    if (_busy) return;
    _busy = true;
    state = const AsyncLoading();
    try {
      final controllerAsync = ref.read(cameraControllerNotifierProvider);
      final controller = controllerAsync.valueOrNull;
      if (controller == null || !controller.value.isInitialized) {
        throw CameraException('not_ready', 'Camera is not ready yet.');
      }
      final xfile = await ref.read(cameraRepositoryProvider).takePicture(controller);
      final albumName = ref.read(selectedAlbumNotifierProvider);
      await ref.read(galleryRepositoryProvider).saveImageIntoAlbum(
            filePath: xfile.path,
            albumName: albumName,
          );
      // DR-7/DR-15: lastUsedAlbum (Initial Album Focus) updates only after a
      // successful capture — never on mere carousel selection/browsing, and
      // never on album creation alone (see selected_album_provider.dart).
      await ref.read(settingsRepositoryProvider).setLastUsedAlbum(albumName);
      ref.invalidate(albumListProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _busy = false;
    }
  }
}
