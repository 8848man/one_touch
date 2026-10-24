import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album.dart';
import '../../../core/providers.dart';
import '../../albums/application/albums_controller.dart';
import '../../albums/application/media_providers.dart';

enum CaptureMode { photo, video }

const kSaveFailedMessage = '저장하지 못했어요. 다시 시도해 주세요.';

class CameraState {
  const CameraState({
    this.controller,
    this.cameras = const [],
    this.lensIndex = 0,
    this.mode = CaptureMode.photo,
    this.isBusy = false,
    this.isRecording = false,
    this.recordingSince,
    this.error,
    this.flashTick = 0,
  });

  final CameraController? controller;
  final List<CameraDescription> cameras;
  final int lensIndex;
  final CaptureMode mode;
  final bool isBusy;
  final bool isRecording;
  final DateTime? recordingSince;
  final String? error;

  /// Incremented on every photo so the UI can play the shutter flash.
  final int flashTick;

  bool get isReady => controller?.value.isInitialized ?? false;

  CameraState copyWith({
    CameraController? controller,
    bool clearController = false,
    List<CameraDescription>? cameras,
    int? lensIndex,
    CaptureMode? mode,
    bool? isBusy,
    bool? isRecording,
    DateTime? recordingSince,
    bool clearRecordingSince = false,
    String? error,
    bool clearError = false,
    int? flashTick,
  }) {
    return CameraState(
      controller: clearController ? null : (controller ?? this.controller),
      cameras: cameras ?? this.cameras,
      lensIndex: lensIndex ?? this.lensIndex,
      mode: mode ?? this.mode,
      isBusy: isBusy ?? this.isBusy,
      isRecording: isRecording ?? this.isRecording,
      recordingSince: clearRecordingSince ? null : (recordingSince ?? this.recordingSince),
      error: clearError ? null : (error ?? this.error),
      flashTick: flashTick ?? this.flashTick,
    );
  }
}

/// Owns the CameraController lifecycle and capture/record → save.
/// The busy lock is carried over from the MVP capture_and_save_provider:
/// a rapid double tap otherwise throws a CameraException.
class CameraNotifier extends Notifier<CameraState> {
  Future<void>? _startFuture;
  bool _openedWithAudio = false;
  Album? _recordingAlbum;
  CameraController? _active;
  Future<void>? _stopping;

  /// False once [stop] was requested, so a start still in flight backs off.
  bool _wantRunning = true;

  @override
  CameraState build() {
    ref.onDispose(() => _active?.dispose());
    Future.microtask(start);
    return const CameraState();
  }

  Future<void> start() {
    _wantRunning = true;
    if (state.controller != null) return Future<void>.value();
    return _startFuture ??= _open().whenComplete(() => _startFuture = null);
  }

  Future<void> _open() async {
    try {
      // Let a pending release finish first, or the camera may still be busy.
      await _stopping;
      final service = ref.read(cameraServiceProvider);
      final cameras = state.cameras.isEmpty ? await service.cameras() : state.cameras;
      if (cameras.isEmpty) {
        state = state.copyWith(error: '사용할 수 있는 카메라가 없어요.');
        return;
      }
      final index = state.lensIndex < cameras.length ? state.lensIndex : 0;
      final mic = ref.read(permissionProvider).valueOrNull?.microphone ?? false;
      final controller = await service.open(cameras[index], enableAudio: mic);
      if (!_wantRunning) {
        await controller.dispose();
        return;
      }
      _active = controller;
      _openedWithAudio = mic;
      state = state.copyWith(controller: controller, cameras: cameras, lensIndex: index, clearError: true);
    } catch (_) {
      state = state.copyWith(error: '카메라를 열 수 없어요.');
    }
  }

  /// Releases the camera (app paused). A running recording is discarded.
  Future<void> stop() {
    _wantRunning = false;
    final controller = state.controller;
    if (controller == null) return _stopping ?? Future<void>.value();
    _active = null;
    state = state.copyWith(clearController: true, isRecording: false, clearRecordingSince: true, isBusy: false);
    _recordingAlbum = null;
    final stopping = _release(controller);
    _stopping = stopping;
    return stopping.whenComplete(() {
      if (identical(_stopping, stopping)) _stopping = null;
    });
  }

  Future<void> _release(CameraController controller) async {
    try {
      if (controller.value.isRecordingVideo) await controller.stopVideoRecording();
    } catch (_) {
      // Ignored: the controller is being torn down anyway.
    }
    await controller.dispose();
  }

  Future<void> switchLens() async {
    if (state.isRecording || state.isBusy || state.cameras.length < 2) return;
    final next = (state.lensIndex + 1) % state.cameras.length;
    await stop();
    state = state.copyWith(lensIndex: next);
    await start();
  }

  bool _micAsked = false;

  /// Switches photo/video. The first switch to video asks for the microphone
  /// (screens.md §0); when granted, the camera reopens with audio.
  /// Returns a notice for the UI, or null.
  Future<String?> setMode(CaptureMode mode) async {
    if (state.isRecording || state.isBusy) return null;
    state = state.copyWith(mode: mode);
    if (mode != CaptureMode.video) return null;
    final permission = ref.read(permissionProvider.notifier);
    final hasMic = ref.read(permissionProvider).valueOrNull?.microphone ?? false;
    if (hasMic) return null;
    if (_micAsked) return null;
    _micAsked = true;
    final granted = await permission.requestMicrophone();
    if (!granted) return '마이크 권한이 없어 소리 없이 녹화돼요.';
    // The system dialog pauses the app, so a restart may be in flight;
    // wait for it, then reopen if the controller was opened without audio.
    await _startFuture;
    if (state.controller != null && !_openedWithAudio && !state.isRecording && !state.isBusy) {
      await stop();
      await start();
    }
    return null;
  }

  /// Shutter tap. Returns a user-facing error message, or null on success.
  Future<String?> shutter() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return '카메라가 아직 준비되지 않았어요.';
    if (state.isRecording) return _stopRecording(controller);
    if (state.isBusy) return null;
    final album = ref.read(albumsProvider).selected;
    if (album == null) return '먼저 앨범을 만들어 주세요.';
    return state.mode == CaptureMode.photo ? _takePhoto(controller, album) : _startRecording(controller, album);
  }

  Future<String?> _takePhoto(CameraController controller, Album album) async {
    state = state.copyWith(isBusy: true);
    try {
      final file = await controller.takePicture();
      state = state.copyWith(flashTick: state.flashTick + 1);
      await ref
          .read(mediaGalleryProvider)
          .saveImage(file.path, relativePath: album.savePath, fallbackPath: album.fallbackSavePath);
      await _afterSave(album);
      return null;
    } catch (_) {
      return kSaveFailedMessage;
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<String?> _startRecording(CameraController controller, Album album) async {
    state = state.copyWith(isBusy: true);
    try {
      await controller.startVideoRecording();
      _recordingAlbum = album;
      state = state.copyWith(isRecording: true, recordingSince: DateTime.now());
      return null;
    } catch (_) {
      return '녹화를 시작할 수 없어요.';
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<String?> _stopRecording(CameraController controller) async {
    final album = _recordingAlbum;
    state = state.copyWith(isBusy: true);
    try {
      final file = await controller.stopVideoRecording();
      state = state.copyWith(isRecording: false, clearRecordingSince: true);
      if (album == null) return kSaveFailedMessage;
      await ref
          .read(mediaGalleryProvider)
          .saveVideo(file.path, relativePath: album.savePath, fallbackPath: album.fallbackSavePath);
      await _afterSave(album);
      return null;
    } catch (_) {
      state = state.copyWith(isRecording: false, clearRecordingSince: true);
      return kSaveFailedMessage;
    } finally {
      _recordingAlbum = null;
      state = state.copyWith(isBusy: false);
    }
  }

  Future<void> _afterSave(Album album) async {
    await ref.read(albumsProvider.notifier).markUsed(album.id);
    refreshMedia(ref);
  }
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(CameraNotifier.new);
