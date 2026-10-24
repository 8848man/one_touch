import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/device_services.dart';
import 'data/local_store.dart';
import 'data/media_gallery.dart';

/// Root DI (architecture/dependency_injection.md). Plain providers instead of
/// riverpod_generator so the prototype builds without build_runner.

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main() and in tests.'),
);

final albumStoreProvider = Provider<AlbumStore>((ref) => AlbumStore(ref.watch(sharedPreferencesProvider)));

final appPrefsProvider = Provider<AppPrefs>((ref) => AppPrefs(ref.watch(sharedPreferencesProvider)));

final mediaGalleryProvider = Provider<MediaGallery>((ref) => MediaGallery());

final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());

final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService());

/// Permission state. Starts by reading the current status (no dialog);
/// dialogs are shown only through [PermissionNotifier.requestEssentials] and
/// [PermissionNotifier.requestMicrophone].
class PermissionNotifier extends AsyncNotifier<PermissionSnapshot> {
  PermissionService get _service => ref.read(permissionServiceProvider);

  @override
  Future<PermissionSnapshot> build() => _service.status();

  Future<void> requestEssentials() async {
    state = await AsyncValue.guard(_service.requestEssentials);
  }

  /// Re-reads the status, e.g. after returning from the system settings.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_service.status);
  }

  Future<bool> requestMicrophone() async {
    final granted = await _service.requestMicrophone();
    final current = state.valueOrNull;
    if (current != null) state = AsyncData(current.copyWith(microphone: granted));
    return granted;
  }
}

final permissionProvider =
    AsyncNotifierProvider<PermissionNotifier, PermissionSnapshot>(PermissionNotifier.new);
