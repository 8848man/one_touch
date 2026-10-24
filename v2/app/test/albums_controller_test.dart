import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch_camera_v2/core/domain/album_rules.dart';
import 'package:one_touch_camera_v2/core/providers.dart';
import 'package:one_touch_camera_v2/features/albums/application/albums_controller.dart';
import 'package:one_touch_camera_v2/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  ProviderContainer newContainer() =>
      ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = newContainer();
  });

  tearDown(() => container.dispose());

  AlbumsNotifier notifier() => container.read(albumsProvider.notifier);
  AlbumsState state() => container.read(albumsProvider);

  test('create appends the album and selects it (V5)', () async {
    await notifier().create('여행');
    final second = await notifier().create('업무');
    expect(state().albums.map((a) => a.displayName), ['여행', '업무']);
    expect(state().selectedId, second.id);
    expect(second.isVisible, isTrue);
  });

  test('create rejects duplicate names (V4)', () async {
    await notifier().create('여행');
    await expectLater(notifier().create(' 여행 '), throwsArgumentError);
  });

  test('free users may keep only 3 albums on; premium lifts it (V13)', () async {
    for (var i = 0; i < kFreeActiveAlbumLimit; i++) {
      await notifier().create('앨범$i');
    }
    expect(notifier().canActivateMore, isFalse);

    // Turning one off frees a slot; turning a 4th on is refused.
    final first = state().albums.first;
    await notifier().setVisible(first.id, false);
    expect(notifier().canActivateMore, isTrue);
    await notifier().create('추가');
    expect(await notifier().setVisible(first.id, true), isFalse);
    expect(state().albums.first.isVisible, isFalse);

    await container.read(premiumProvider.notifier).setPremium(true);
    expect(await notifier().setVisible(first.id, true), isTrue);
    expect(state().visible, hasLength(4));
  });

  test('first import with no albums turns on recent folders and selects one (V16)', () async {
    await notifier().importFolders([
      GalleryFolder(name: 'Camera', count: 10, latestAt: DateTime(2026, 9, 3), relativePath: 'DCIM/Camera/'),
      GalleryFolder(name: 'Trip', count: 2, latestAt: DateTime(2026, 9, 2)),
      GalleryFolder(name: 'Work', count: 2, latestAt: DateTime(2026, 9, 1)),
      GalleryFolder(name: 'Old', count: 2, latestAt: DateTime(2025, 1, 1)),
    ]);
    expect(state().albums, hasLength(4));
    expect(state().visible.map((a) => a.displayName), ['Camera', 'Trip', 'Work']);
    expect(state().selected?.displayName, 'Camera');

    // Later imports never switch anything on.
    await notifier().importFolders([GalleryFolder(name: 'New', count: 1, latestAt: DateTime(2026, 10, 1))]);
    expect(state().albums.last.displayName, 'New');
    expect(state().albums.last.isVisible, isFalse);
  });

  test('a deleted imported album is not imported again (V18)', () async {
    await notifier().create('Mine');
    await notifier().importFolders([GalleryFolder(name: 'Camera', count: 3)]);
    final camera = state().albums.firstWhere((a) => a.isImported);
    await notifier().delete(camera.id);
    await notifier().importFolders([GalleryFolder(name: 'Camera', count: 3)]);
    expect(state().albums.map((a) => a.displayName), ['Mine']);

    // Creating an album with that folder name brings the folder back into use.
    await notifier().create('Camera');
    expect(state().albums.map((a) => a.folderName), ['Mine', 'Camera']);
  });

  test('hiding the selected album reselects a visible one (V9) and none leaves null (V10)', () async {
    final a = await notifier().create('A');
    final b = await notifier().create('B');
    await notifier().markUsed(a.id);
    notifier().select(b.id);
    await notifier().setVisible(b.id, false);
    expect(state().selectedId, a.id);
    await notifier().setVisible(a.id, false);
    expect(state().selectedId, isNull);
    expect(state().albums, hasLength(2), reason: 'hidden albums stay in the list');
  });

  test('rename changes the display name and the device folder (V7)', () async {
    final a = await notifier().create('여행');
    // No platform gallery in tests: the folder is empty, so the move is a no-op.
    expect(await notifier().rename(a.id, '제주 여행'), RenameResult.renamed);
    final renamed = state().albums.single;
    expect(renamed.displayName, '제주 여행');
    expect(renamed.folderName, '제주 여행');
    expect(renamed.savePath, 'Pictures/제주 여행');
    expect(renamed.isVisible, isTrue);
  });

  test('renaming an imported album keeps its parent folder (V7)', () async {
    await notifier().importFolders([
      GalleryFolder(name: 'Camera', count: 3, latestAt: DateTime(2026, 9, 1), relativePath: 'DCIM/Camera/'),
    ]);
    final camera = state().albums.single;
    await notifier().rename(camera.id, '폰카');
    final renamed = state().albums.single;
    expect(renamed.folderName, '폰카');
    expect(renamed.savePath, 'DCIM/폰카/');
  });

  test('delete removes only the record and reselects (V8)', () async {
    final a = await notifier().create('A');
    final b = await notifier().create('B');
    await notifier().delete(b.id);
    expect(state().albums.map((e) => e.id), [a.id]);
    expect(state().selectedId, a.id);
  });

  test('reorder follows ReorderableListView indices (V12)', () async {
    await notifier().create('A');
    await notifier().create('B');
    await notifier().create('C');
    await notifier().reorder(0, 3); // move A to the end
    expect(state().albums.map((a) => a.displayName), ['B', 'C', 'A']);
    expect(state().albums.map((a) => a.sortOrder), [0, 1, 2]);
  });

  test('albums and last-used selection persist across restarts (V11)', () async {
    await notifier().create('A');
    final b = await notifier().create('B');
    final a = state().albums.first;
    await notifier().markUsed(a.id);
    expect(b.id, isNot(a.id));

    container.dispose();
    container = newContainer();
    expect(state().albums.map((e) => e.displayName), ['A', 'B']);
    expect(state().selectedId, a.id);
  });
}
