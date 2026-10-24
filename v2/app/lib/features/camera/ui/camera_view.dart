import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album_rules.dart';
import '../../../design_system/design_system.dart';
import '../../albums/application/albums_controller.dart';
import '../../albums/application/media_providers.dart';
import '../../albums/ui/album_dialogs.dart';
import '../../albums/ui/album_media_screen.dart';
import '../../albums/ui/asset_thumbnail.dart';
import '../application/camera_notifier.dart';

/// Camera screen (screens.md §1). [expanded] switches to the foldable layout
/// (screens.md §7, reference 15_galaxy_fold_expand.png).
class CameraView extends ConsumerWidget {
  const CameraView({
    super.key,
    required this.expanded,
    required this.onOpenAlbums,
    required this.onOpenSettings,
  });

  final bool expanded;
  final VoidCallback onOpenAlbums;
  final VoidCallback onOpenSettings;

  Future<void> _shutter(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(cameraProvider.notifier).shutter();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider);
    final albums = ref.watch(albumsProvider);
    final notifier = ref.read(cameraProvider.notifier);
    final locked = camera.isRecording || camera.isBusy;

    final modeToggle = ModeToggle(
      isVideo: camera.mode == CaptureMode.video,
      enabled: !locked,
      onChanged: (video) async {
        final notice = await notifier.setMode(video ? CaptureMode.video : CaptureMode.photo);
        if (notice != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(notice)));
        }
      },
    );
    final shutter = ShutterButton(
      recording: camera.isRecording,
      enabled: camera.isReady && albums.selected != null && !camera.isBusy,
      onPressed: () => _shutter(context, ref),
    );
    final flip = RoundIconButton(
      icon: Icons.cameraswitch_outlined,
      tooltip: '전면/후면 전환',
      onPressed: locked || camera.cameras.length < 2 ? null : notifier.switchLens,
    );
    const thumbnail = _LatestThumbnail();
    final chips = _AlbumChips(locked: camera.isRecording);
    final listButton = BarIconButton(icon: Icons.format_list_bulleted, tooltip: '앨범 리스트', onPressed: onOpenAlbums);
    final settingsButton = BarIconButton(icon: Icons.settings_outlined, tooltip: '설정', onPressed: onOpenSettings);

    if (expanded) {
      return Scaffold(
        backgroundColor: AppColors.cameraSurface,
        body: Row(
          children: [
            SizedBox(
              width: AppSize.railWidth,
              child: SafeArea(
                right: false,
                child: Column(
                  children: [const SizedBox(height: AppSpace.s), settingsButton, listButton],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: _Preview()),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpace.m),
                        child: Center(child: modeToggle),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: AppSpace.s),
                      child: Padding(padding: const EdgeInsets.only(bottom: AppSpace.l), child: chips),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: AppSize.expandedControlsWidth,
              child: SafeArea(
                left: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    flip,
                    const SizedBox(height: AppSpace.xl),
                    shutter,
                    const SizedBox(height: AppSpace.xl),
                    thumbnail,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cameraSurface,
      body: Column(
        children: [
          CameraTopBar(leading: [listButton], trailing: [settingsButton]),
          const Expanded(child: _Preview()),
          // Extra room under the chips so a tap near the bottom edge does not
          // land on the system navigation bar / home gesture (screens.md §1).
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: AppSpace.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpace.m),
                modeToggle,
                const SizedBox(height: AppSpace.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [thumbnail, shutter, flip],
                ),
                const SizedBox(height: AppSpace.m),
                chips,
                const SizedBox(height: AppSpace.l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider);
    final controller = camera.controller;
    Widget content;
    if (controller != null && controller.value.isInitialized) {
      final size = controller.value.previewSize;
      content = size == null
          ? CameraPreview(controller)
          : ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                // previewSize is reported in landscape; swap for portrait.
                child: SizedBox(width: size.height, height: size.width, child: CameraPreview(controller)),
              ),
            );
    } else if (camera.error != null) {
      content = Center(
        child: Text(camera.error!, style: const TextStyle(color: AppColors.onCameraMuted)),
      );
    } else {
      content = const Center(child: CircularProgressIndicator(color: AppColors.onCamera));
    }
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          _ShutterFlash(tick: camera.flashTick),
          if (camera.isRecording && camera.recordingSince != null)
            Positioned(
              top: AppSpace.m,
              left: 0,
              right: 0,
              child: Center(child: _RecordingBadge(since: camera.recordingSince!)),
            ),
        ],
      ),
    );
  }
}

class _AlbumChips extends ConsumerWidget {
  const _AlbumChips({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    final visible = albums.visible;
    if (visible.isEmpty) {
      // V10 — no visible album: no capture, prompt to create one.
      return SizedBox(
        height: AppSize.chipBarHeight,
        child: Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.onCamera),
            icon: const Icon(Icons.add, size: 18),
            label: Text(albums.albums.isEmpty ? '앨범을 만들어 주세요' : '표시할 앨범을 켜 주세요'),
            onPressed: () => showCreateAlbumFlow(context, ref),
          ),
        ),
      );
    }
    return AlbumChipBar(
      items: [for (final a in visible) AlbumChipItem(id: a.id, label: chipLabel(a.displayName))],
      selectedId: albums.selectedId,
      enabled: !locked,
      onSelected: ref.read(albumsProvider.notifier).select,
      trailing: AlbumAddChip(onTap: locked ? null : () => showCreateAlbumFlow(context, ref)),
    );
  }
}

class _LatestThumbnail extends ConsumerWidget {
  const _LatestThumbnail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumsProvider).selected;
    final latest = album == null ? null : ref.watch(latestMediaProvider(album.folderName)).valueOrNull;
    return Semantics(
      button: true,
      label: '앨범 사진 보기',
      child: GestureDetector(
        onTap: album == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => AlbumMediaScreen(album: album)),
                ),
        child: Container(
          width: AppSize.sideButtonSize,
          height: AppSize.sideButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.placeholder,
            border: Border.all(color: AppColors.onCamera, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: latest == null ? null : AssetThumbnail(asset: latest, size: 120),
        ),
      ),
    );
  }
}

class _ShutterFlash extends StatefulWidget {
  const _ShutterFlash({required this.tick});

  final int tick;

  @override
  State<_ShutterFlash> createState() => _ShutterFlashState();
}

class _ShutterFlashState extends State<_ShutterFlash> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppMotion.fast);

  @override
  void didUpdateWidget(_ShutterFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tick != widget.tick) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final double opacity = _controller.isAnimating ? (t < 0.5 ? t * 1.2 : (1 - t) * 1.2) : 0.0;
          return ColoredBox(color: Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble()));
        },
      ),
    );
  }
}

class _RecordingBadge extends StatefulWidget {
  const _RecordingBadge({required this.since});

  final DateTime since;

  @override
  State<_RecordingBadge> createState() => _RecordingBadgeState();
}

class _RecordingBadgeState extends State<_RecordingBadge> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.since);
    final mm = elapsed.inMinutes.toString().padLeft(2, '0');
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.xs),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 10, color: AppColors.recording),
          const SizedBox(width: AppSpace.s),
          Text('$mm:$ss', style: const TextStyle(color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
