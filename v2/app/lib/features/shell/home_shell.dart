import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens.dart';
import '../albums/application/albums_controller.dart';
import '../albums/ui/album_list_screen.dart';
import '../camera/application/camera_notifier.dart';
import '../camera/ui/camera_view.dart';
import '../settings/ui/settings_screen.dart';

/// Picks the phone or foldable layout and releases the camera while the app
/// is in the background.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  /// Foldable only: album list shown as the left pane (reference 16).
  bool _splitList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // V15/V16 — import device gallery folders (first run turns on recent ones).
    Future.microtask(() => ref.read(albumsProvider.notifier).syncWithGallery());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = ref.read(cameraProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        camera.start();
        ref.read(albumsProvider.notifier).syncWithGallery();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        camera.stop();
      case AppLifecycleState.detached:
        break;
    }
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _pushAlbumList() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AlbumListScreen(onOpenSettings: _openSettings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= AppSize.expandedBreakpoint;
        if (!expanded) {
          return CameraView(expanded: false, onOpenAlbums: _pushAlbumList, onOpenSettings: _openSettings);
        }
        if (_splitList) {
          return Row(
            children: [
              Expanded(
                child: AlbumListScreen(
                  onOpenSettings: _openSettings,
                  onClose: () => setState(() => _splitList = false),
                ),
              ),
              Expanded(
                child: CameraView(
                  expanded: false,
                  onOpenAlbums: () => setState(() => _splitList = false),
                  onOpenSettings: _openSettings,
                ),
              ),
            ],
          );
        }
        return CameraView(
          expanded: true,
          onOpenAlbums: () => setState(() => _splitList = true),
          onOpenSettings: _openSettings,
        );
      },
    );
  }
}
