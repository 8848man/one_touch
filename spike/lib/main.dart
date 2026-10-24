// MINIMAL DEVICE VALIDATION SPIKE — not production code.
// Validates only: Pending Album -> Capture -> MediaStore Album -> Save -> Verify.
// No Riverpod, no MVVM, no navigation, no widget library. Plain StatefulWidget + setState.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

const String kTargetAlbumName = 'OneTouchSpike';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MaterialApp(home: SpikeHomePage()));
}

class SpikeHomePage extends StatefulWidget {
  const SpikeHomePage({super.key});
  @override
  State<SpikeHomePage> createState() => _SpikeHomePageState();
}

class _SpikeHomePageState extends State<SpikeHomePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  final List<String> _log = [];
  bool _pendingAlbum = true; // Validation 2: starts pending until first photo saved
  int _captureCount = 0;

  void _addLog(String msg) {
    debugPrint('[SPIKE] $msg');
    setState(() => _log.insert(0, msg));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Validation prerequisite: permissions
    final camStatus = await Permission.camera.request();
    _addLog('Camera permission: $camStatus');

    final phStatus = await PhotoManager.requestPermissionExtend();
    _addLog('Photo permission: ${phStatus.name} (isAuth=${phStatus.isAuth}, hasAccess=${phStatus.hasAccess})');

    if (!phStatus.hasAccess || camStatus != PermissionStatus.granted) {
      _addLog('BLOCKED: missing permission(s), cannot proceed.');
      return;
    }

    await _initCamera();

    // Check pending state: does the target album already exist from a previous run?
    final existing = await _findTargetAlbum();
    setState(() => _pendingAlbum = existing == null);
    _addLog(existing == null
        ? 'Pending Album state: TRUE (album "$kTargetAlbumName" does not exist yet)'
        : 'Pending Album state: FALSE (album already exists, assetCount=${await existing.assetCountAsync})');
  }

  Future<void> _initCamera() async {
    if (_cameras.isEmpty) {
      _addLog('No cameras available on this device/emulator.');
      return;
    }
    final controller = CameraController(_cameras.first, ResolutionPreset.medium);
    _controller = controller;
    await controller.initialize();
    _addLog('Camera initialized: ${_cameras.first.name}, lensDirection=${_cameras.first.lensDirection}');
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<AssetPathEntity?> _findTargetAlbum() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
    );
    for (final p in paths) {
      if (p.name == kTargetAlbumName) return p;
    }
    return null;
  }

  // Fallback path added after the emulator's camera HAL proved unreliable
  // (reproducible ERROR_CAMERA_IN_USE / DEAD_OBJECT). Isolates validation of
  // the save->album->EXIF->gallery pipeline from the flaky emulated camera.
  Future<void> _saveTestImageBypassingCamera() async {
    const testPath = '/sdcard/Download/spike_test_source.jpg';
    try {
      final beforeAlbum = await _findTargetAlbum();
      final wasPending = beforeAlbum == null;
      _addLog('[BYPASS] Album exists before save? ${!wasPending}');

      final asset = await PhotoManager.editor.saveImageWithPath(
        testPath,
        title: 'spike_bypass_${DateTime.now().millisecondsSinceEpoch}.jpg',
        relativePath: Platform.isAndroid ? 'Pictures/$kTargetAlbumName' : null,
      );
      _addLog('[BYPASS] Saved as AssetEntity id=${asset.id}');

      final afterAlbum = await _findTargetAlbum();
      if (afterAlbum == null) {
        _addLog('[BYPASS] FAIL: target album still not found after save.');
      } else {
        final count = await afterAlbum.assetCountAsync;
        _addLog('[BYPASS] Album "$kTargetAlbumName" now has assetCount=$count');
        setState(() {
          _pendingAlbum = false;
          _captureCount++;
        });
        _addLog(wasPending
            ? '[BYPASS] Pending -> Created transition confirmed.'
            : '[BYPASS] Saved into pre-existing album (repeat).');
      }

      final refreshed = await asset.obtainForNewProperties() ?? asset;
      _addLog('[BYPASS] createDateSecond=${refreshed.createDateSecond} '
          '(${refreshed.createDateTime.toIso8601String()})');
      _addLog('[BYPASS] orientation=${refreshed.orientation}');
      _addLog('[BYPASS] latLng=${refreshed.latitude}, ${refreshed.longitude}');
      _addLog('[BYPASS] width=${refreshed.width} height=${refreshed.height} mimeType=${refreshed.mimeType}');
    } catch (e, st) {
      _addLog('[BYPASS] EXCEPTION during save: $e');
      debugPrint('$st');
    }
  }

  Future<void> _captureAndSave() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _addLog('FAIL: camera not initialized.');
      return;
    }
    try {
      // --- Step: Take Photo ---
      final xfile = await controller.takePicture();
      _addLog('Captured photo: ${xfile.path}');

      final beforeAlbum = await _findTargetAlbum();
      final wasPending = beforeAlbum == null;
      _addLog('Album exists before save? ${!wasPending}');

      // --- Step: Save Photo into Album (Android: relativePath creates the
      // MediaStore bucket on first write if it does not already exist — this
      // is the "Create MediaStore Album" step, folded into one call on Android). ---
      final asset = await PhotoManager.editor.saveImageWithPath(
        xfile.path,
        title: 'spike_${DateTime.now().millisecondsSinceEpoch}.jpg',
        relativePath: Platform.isAndroid ? 'Pictures/$kTargetAlbumName' : null,
      );
      _addLog('Saved as AssetEntity id=${asset.id}');

      // --- Step: Verify Gallery ---
      final afterAlbum = await _findTargetAlbum();
      if (afterAlbum == null) {
        _addLog('FAIL: target album still not found after save (Validation 1 & 2 FAIL).');
      } else {
        final count = await afterAlbum.assetCountAsync;
        _addLog('Album "$kTargetAlbumName" now has assetCount=$count');
        setState(() {
          _pendingAlbum = false;
          _captureCount++;
        });
        _addLog(wasPending
            ? 'Pending -> Created transition confirmed (Validation 2 PASS so far).'
            : 'Saved into pre-existing album (repeat capture).');
      }

      // --- EXIF-relevant fields (Validation 3) ---
      final refreshed = await asset.obtainForNewProperties() ?? asset;
      _addLog('createDateSecond=${refreshed.createDateSecond} '
          '(${refreshed.createDateTime.toIso8601String()})');
      _addLog('orientation=${refreshed.orientation}');
      _addLog('latLng=${refreshed.latitude}, ${refreshed.longitude}');
      _addLog('width=${refreshed.width} height=${refreshed.height} mimeType=${refreshed.mimeType}');
    } catch (e, st) {
      _addLog('EXCEPTION during capture/save: $e');
      debugPrint('$st');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Device Validation Spike')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Pending Album: $_pendingAlbum   |   Captures this run: $_captureCount',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (controller != null && controller.value.isInitialized)
            SizedBox(height: 240, child: CameraPreview(controller))
          else
            const SizedBox(height: 240, child: Center(child: Text('camera not ready'))),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _captureAndSave,
              child: const Text('CAPTURE + SAVE TO ALBUM'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton(
              onPressed: _saveTestImageBypassingCamera,
              child: const Text('SAVE TEST IMAGE (bypass camera)'),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(_log[i], style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
