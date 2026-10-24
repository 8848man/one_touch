import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/domain/repositories/settings_repository.dart';
import 'features/camera_album/application/selected_album_provider.dart';
import 'features/camera_album/data/settings_repository_impl.dart';
import 'features/camera_album/presentation/camera_album_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Resolve Initial Album Focus (DR-7) before first frame, so the shutter
  // and carousel never flash the hardcoded default before restoring the
  // real last-used album on a returning launch.
  final SettingsRepository settingsRepository = SettingsRepositoryImpl();
  final lastUsedAlbum = await settingsRepository.getLastUsedAlbum();

  runApp(
    ProviderScope(
      overrides: [
        if (lastUsedAlbum != null) initialAlbumFocusProvider.overrideWithValue(lastUsedAlbum),
      ],
      child: const OneTouchApp(),
    ),
  );
}

class OneTouchApp extends StatelessWidget {
  const OneTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraAlbumScreen(),
    );
  }
}
