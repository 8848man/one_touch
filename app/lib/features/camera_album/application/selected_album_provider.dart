import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_album_provider.g.dart';

/// Default is a Pending Album (sdd DR-9): it does not exist in the device
/// gallery until the first photo is saved into it.
const defaultAlbumName = 'OneTouch';

/// Initial Album Focus (sdd DR-7) — overridden at app startup in main.dart
/// with the persisted last-used album, if one exists. Kept as a separate
/// provider (rather than reading SettingsRepository directly in
/// SelectedAlbumNotifier.build()) so the notifier's build() stays
/// synchronous and every existing `ref.watch(selectedAlbumNotifierProvider)`
/// call site continues to receive a plain String, not an AsyncValue.
@riverpod
String initialAlbumFocus(InitialAlbumFocusRef ref) => defaultAlbumName;

@riverpod
class SelectedAlbumNotifier extends _$SelectedAlbumNotifier {
  @override
  String build() => ref.watch(initialAlbumFocusProvider);

  void select(String albumName) => state = albumName;
}
