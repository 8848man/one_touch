import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/album.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../application/album_list_provider.dart';
import '../application/camera_controller_provider.dart';
import '../application/capture_and_save_provider.dart';
import '../application/permission_provider.dart';
import '../application/selected_album_provider.dart';
import 'album_management_sheet.dart';
import 'widgets/album_reel.dart';
import 'widgets/shutter_pin.dart';

class CameraAlbumScreen extends ConsumerStatefulWidget {
  const CameraAlbumScreen({super.key});

  @override
  ConsumerState<CameraAlbumScreen> createState() => _CameraAlbumScreenState();
}

class _CameraAlbumScreenState extends ConsumerState<CameraAlbumScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Required per infra/camera-integration.md: the `camera` plugin no
    // longer manages lifecycle transitions itself since v0.5.0.
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      ref.invalidate(cameraControllerNotifierProvider);
    } else if (state == AppLifecycleState.resumed) {
      ref.invalidate(cameraControllerNotifierProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionStatusNotifierProvider);

    return Scaffold(
      body: permission.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _PermissionDenied(
          onRetry: () => ref.read(permissionStatusNotifierProvider.notifier).retry(),
        ),
        data: (granted) => granted
            ? const _CameraBody()
            : _PermissionDenied(
                onRetry: () => ref.read(permissionStatusNotifierProvider.notifier).retry(),
              ),
      ),
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Camera and photo access are required.'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Grant access')),
        ],
      ),
    );
  }
}

class _CameraBody extends ConsumerStatefulWidget {
  const _CameraBody();

  @override
  ConsumerState<_CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends ConsumerState<_CameraBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    // save-flow.md success feedback: a brief full-screen flash only — no
    // preview, toast, or result popup (Assumption on exact timing, see
    // sdd/fe/ux/interaction-patterns.md).
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      // Starts at 1 (opacity 0, see build()) so the overlay is invisible
      // before the first capture; forward(from: 0) then plays a 0->1 flash-
      // and-fade on every successful save.
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _showFailureModal(Object error) {
    // save-flow.md failure path: modal with message, confirm returns to the
    // same camera screen state — no navigation away, no silent retry.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('사진 저장에 실패했습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  List<Album> _withPendingSelection(List<Album> albums, String selectedAlbumName) {
    if (albums.any((a) => a.name == selectedAlbumName)) return albums;
    // sdd/core/domain/domain-rules.md DR-9: the selected album may not exist
    // in the device gallery yet (first-run default, or a name chosen before
    // its first photo is written) — represent it as a Pending Album so the
    // reel/shutter still have something valid to display and select.
    return [
      Album(name: selectedAlbumName, assetCount: 0, isPending: true),
      ...albums,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraControllerNotifierProvider);
    // Carousel/shutter consume visible albums only (DR-11) — Album
    // Management (not this screen) is where hidden albums are still shown.
    final albumsAsync = ref.watch(visibleAlbumsProvider);
    final selectedAlbum = ref.watch(selectedAlbumNotifierProvider);
    final captureState = ref.watch(captureAndSaveNotifierProvider);

    ref.listen<AsyncValue<void>>(captureAndSaveNotifierProvider, (previous, next) {
      if (previous is! AsyncLoading) return;
      next.when(
        data: (_) => _flashController.forward(from: 0),
        error: (error, _) => _showFailureModal(error),
        loading: () {},
      );
    });

    final rawAlbums = albumsAsync.valueOrNull ?? const [];
    final albums = _withPendingSelection(rawAlbums, selectedAlbum);
    // TEMP DIAGNOSTIC — pipeline audit, stage 5: immediately before AlbumReel
    // is built. Print-only.
    // ignore: avoid_print
    print('[PIPELINE_AUDIT] === STAGE 5: before AlbumReel — '
        'count=${albums.length} names=${albums.map((a) => a.name).toList()} '
        'selected="$selectedAlbum" ===');

    return Stack(
      fit: StackFit.expand,
      children: [
        cameraAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Camera error: $e')),
          data: (controller) => CameraPreview(controller),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) => Opacity(
              opacity: (1 - _flashController.value).clamp(0.0, 1.0),
              child: Container(color: Colors.white),
            ),
          ),
        ),
        if (albumsAsync.hasError)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Text(
              'Could not load albums: ${albumsAsync.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        // Top bar — sdd/fe/ui/main-camera-screen.md region table: Album
        // (top-left, sole entry point for lifecycle/visibility per
        // sdd/feature/album/manage-album.md), Album pill (top-center,
        // current selection), Settings (top-right, presence confirmed by
        // §8, contents resolved by sdd/feature/settings/overview.md).
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 4,
          child: TextButton.icon(
            onPressed: () => showAlbumManagementSheet(context),
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
            label: const Text('Album', style: TextStyle(color: Colors.white)),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  selectedAlbum,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => showSettingsSheet(context),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShutterPin(
                    selectedAlbumName: selectedAlbum,
                    enabled: albums.isNotEmpty,
                    isBusy: captureState.isLoading,
                    onCapture: () =>
                        ref.read(captureAndSaveNotifierProvider.notifier).captureAndSave(),
                  ),
                  const SizedBox(height: 12),
                  albumsAsync.isLoading
                      ? const SizedBox(
                          height: 72,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : AlbumReel(
                          albums: albums,
                          selectedAlbumName: selectedAlbum,
                          onSelect: (name) =>
                              ref.read(selectedAlbumNotifierProvider.notifier).select(name),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
