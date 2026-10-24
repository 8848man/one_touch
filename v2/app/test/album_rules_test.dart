import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch_camera_v2/core/domain/album.dart';
import 'package:one_touch_camera_v2/core/domain/album_rules.dart';

Album _album(String id, String name, {bool visible = true, int order = 0, DateTime? usedAt, String? folder}) {
  return Album(
    id: id,
    folderName: folder ?? name,
    displayName: name,
    isVisible: visible,
    sortOrder: order,
    createdAt: DateTime(2026),
    lastUsedAt: usedAt,
  );
}

void main() {
  group('validateAlbumName', () {
    final existing = [_album('1', 'Travel'), _album('2', '서울 여행')];

    test('rejects empty and whitespace-only names', () {
      expect(validateAlbumName('   ', existing), kEmptyNameMessage);
    });

    test('rejects duplicates ignoring case and extra spaces (V4)', () {
      expect(validateAlbumName(' travel ', existing), kDuplicateNameMessage);
      expect(validateAlbumName('서울   여행', existing), kDuplicateNameMessage);
    });

    test('allows keeping the same name when renaming the same album', () {
      expect(validateAlbumName('Travel', existing, exceptId: '1'), isNull);
    });

    test('rejects names longer than the limit and folder-unsafe characters', () {
      expect(validateAlbumName('가' * (kMaxAlbumNameLength + 1), existing), isNotNull);
      expect(validateAlbumName('a/b', existing), isNotNull);
      expect(validateAlbumName('가' * kMaxAlbumNameLength, existing), isNull);
    });
  });

  test('chipLabel truncates after 10 characters (O7)', () {
    expect(chipLabel('여행'), '여행');
    expect(chipLabel('260730_서울여행입니다'), '260730_서울여..');
  });

  test('formatMediaCount hides 0 and caps at 100+', () {
    expect(formatMediaCount(0), isNull);
    expect(formatMediaCount(1), '1');
    expect(formatMediaCount(99), '99');
    expect(formatMediaCount(100), '100+');
    expect(formatMediaCount(512), '100+');
  });

  test('canActivateAlbum limits active albums unless premium (V13)', () {
    expect(canActivateAlbum(activeCount: kFreeActiveAlbumLimit - 1, premium: false), isTrue);
    expect(canActivateAlbum(activeCount: kFreeActiveAlbumLimit, premium: false), isFalse);
    expect(canActivateAlbum(activeCount: 99, premium: true), isTrue);
  });

  group('mergeGalleryFolders (V15/V16/V18)', () {
    final now = DateTime(2026, 10, 8);
    GalleryFolder folder(String name, {int count = 5, int day = 1, String? path}) =>
        GalleryFolder(name: name, count: count, latestAt: DateTime(2026, 9, day), relativePath: path);

    test('adds unknown, non-empty folders as hidden imported albums, newest first', () {
      final existing = [_album('a', '여행', order: 0)];
      final merged = mergeGalleryFolders(
        existing,
        [folder('여행'), folder('Camera', day: 9, path: 'DCIM/Camera/'), folder('Empty', count: 0), folder('Work', day: 3)],
        now: now,
      );
      expect(merged.map((a) => a.displayName), ['여행', 'Camera', 'Work']);
      final camera = merged[1];
      expect(camera.isImported, isTrue);
      expect(camera.isVisible, isFalse);
      expect(camera.relativePath, 'DCIM/Camera/');
      expect(camera.savePath, 'DCIM/Camera/');
      expect(camera.sortOrder, greaterThan(0));
    });

    test('skips dismissed folders and returns the same list when nothing is new', () {
      final existing = [_album('a', 'A')];
      final merged = mergeGalleryFolders(existing, [folder('Old')], now: now, dismissed: {'old'});
      expect(identical(merged, existing), isTrue);
    });

    test('first run switches on the newest non-system folders only', () {
      final merged = mergeGalleryFolders(
        const [],
        [
          folder('Screenshots', day: 30),
          folder('Camera', day: 20),
          folder('Trip', day: 15),
          folder('Work', day: 10),
          folder('Old', day: 1),
        ],
        now: now,
        activateRecent: kFreeActiveAlbumLimit,
      );
      final on = [for (final a in merged) if (a.isVisible) a.displayName];
      expect(on, ['Camera', 'Trip', 'Work']);
      expect(merged.length, 5);
    });

    test('keeps display names unique when a renamed album already uses the name', () {
      final existing = [_album('a', 'Camera', folder: 'MyFolder')];
      final merged = mergeGalleryFolders(existing, [folder('Camera')], now: now);
      expect(merged.last.displayName, 'Camera (2)');
      expect(merged.last.folderName, 'Camera');
    });
  });

  test('uniqueFolderName adds a suffix only when the folder is taken', () {
    final existing = [_album('1', '여행2', folder: '여행'), _album('2', '여행 (2)')];
    expect(uniqueFolderName('업무', existing), '업무');
    expect(uniqueFolderName('여행', existing), '여행 (3)');
  });

  group('resolveSelection (V9/V11)', () {
    test('keeps the preferred album when visible', () {
      final albums = [_album('a', 'A'), _album('b', 'B', order: 1)];
      expect(resolveSelection(albums, preferredId: 'b'), 'b');
    });

    test('falls back to the most recently used visible album', () {
      final albums = [
        _album('a', 'A', usedAt: DateTime(2026, 1, 1)),
        _album('b', 'B', order: 1, visible: false, usedAt: DateTime(2026, 3, 1)),
        _album('c', 'C', order: 2, usedAt: DateTime(2026, 2, 1)),
      ];
      expect(resolveSelection(albums, preferredId: 'b'), 'c');
    });

    test('falls back to the first album in order, or null when none visible', () {
      expect(resolveSelection([_album('x', 'X', order: 5), _album('y', 'Y', order: 1)]), 'y');
      expect(resolveSelection([_album('x', 'X', visible: false)]), isNull);
    });
  });
}
