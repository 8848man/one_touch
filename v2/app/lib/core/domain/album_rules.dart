import 'album.dart';

/// Pure album rules — see v2/sdd_v2/domain-rules.md and scope.md (O4, O7).

const int kMaxAlbumNameLength = 20;
const int kChipLabelLength = 10;
/// V13 — free users may keep this many albums active (visible) at once.
const int kFreeActiveAlbumLimit = 3;
const String kDuplicateNameMessage = '동일한 이름의 앨범이 이미 존재합니다.';
const String kEmptyNameMessage = '앨범 이름을 입력해 주세요.';

final _whitespace = RegExp(r'\s+');
final _forbiddenChars = RegExp(r'[\\/:*?"<>|]');

String normalizeAlbumName(String raw) => raw.trim().replaceAll(_whitespace, ' ');

String _compareKey(String name) => normalizeAlbumName(name).toLowerCase();

/// Returns an error message, or null when [raw] is a valid name (V4).
String? validateAlbumName(String raw, Iterable<Album> existing, {String? exceptId}) {
  final name = normalizeAlbumName(raw);
  if (name.isEmpty) return kEmptyNameMessage;
  if (name.runes.length > kMaxAlbumNameLength) {
    return '앨범 이름은 $kMaxAlbumNameLength자까지 쓸 수 있어요.';
  }
  if (_forbiddenChars.hasMatch(name)) return r'이름에 \ / : * ? " < > | 는 쓸 수 없어요.';
  final key = _compareKey(name);
  final duplicate = existing.any((a) => a.id != exceptId && _compareKey(a.displayName) == key);
  return duplicate ? kDuplicateNameMessage : null;
}

/// Device folder for a new album. Usually the name itself; a suffix is added
/// only when another app album already owns that folder (possible after a
/// rename, since renames keep the old folder — V7).
String uniqueFolderName(String name, Iterable<Album> existing) {
  final taken = existing.map((a) => a.folderName.toLowerCase()).toSet();
  if (!taken.contains(name.toLowerCase())) return name;
  var n = 2;
  while (taken.contains('$name ($n)'.toLowerCase())) {
    n++;
  }
  return '$name ($n)';
}

/// Chip label, truncated with `..` (O7, e.g. `260730_서울여행..`).
String chipLabel(String name) {
  final runes = name.runes.toList();
  if (runes.length <= kChipLabelLength) return name;
  return '${String.fromCharCodes(runes.take(kChipLabelLength))}..';
}

/// 0 → hidden (null), 1–99 → number, 100+ → `100+`.
String? formatMediaCount(int count) {
  if (count <= 0) return null;
  return count >= 100 ? '100+' : '$count';
}

/// V13 — whether one more album may be switched on (or created visible).
bool canActivateAlbum({required int activeCount, required bool premium}) =>
    premium || activeCount < kFreeActiveAlbumLimit;

/// Picks the album to select (V9/V11): [preferredId] if still visible,
/// otherwise the most recently used visible album, otherwise the first in order.
String? resolveSelection(List<Album> albums, {String? preferredId}) {
  final visible = albums.where((a) => a.isVisible).toList();
  if (visible.isEmpty) return null;
  if (preferredId != null && visible.any((a) => a.id == preferredId)) return preferredId;
  final used = visible.where((a) => a.lastUsedAt != null).toList()
    ..sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));
  if (used.isNotEmpty) return used.first.id;
  visible.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return visible.first.id;
}

/// Gallery folders that are imported but never auto-activated (V16).
/// Same names the MVP denylist used (sdd DR-2).
const Set<String> kSystemFolderNames = {
  'Screenshots',
  'Screen recordings',
  'Download',
  'Downloads',
  'WhatsApp Images',
  'WhatsApp Video',
  'KakaoTalk',
  'Messenger',
};

/// One folder (MediaStore bucket) found in the device gallery.
class GalleryFolder {
  const GalleryFolder({
    required this.name,
    required this.count,
    this.relativePath,
    this.latestAt,
  });

  final String name;
  final int count;

  /// e.g. `DCIM/Camera/`; null when unknown.
  final String? relativePath;

  /// Creation time of the newest item, used to pick "recent" albums (V16).
  final DateTime? latestAt;
}

/// V15/V16/V18 — returns [existing] plus one hidden, imported album for every
/// gallery folder the app does not know yet. Folders match albums by
/// [Album.folderName] (case-insensitive). When [activateRecent] > 0 the newest
/// non-system imported folders are switched on (first run only).
List<Album> mergeGalleryFolders(
  List<Album> existing,
  List<GalleryFolder> folders, {
  required DateTime now,
  Set<String> dismissed = const {},
  int activateRecent = 0,
}) {
  final known = {for (final a in existing) a.folderName.toLowerCase()};
  final skip = {for (final d in dismissed) d.toLowerCase()};
  final fresh = [
    for (final f in folders)
      if (f.count > 0 && !known.contains(f.name.toLowerCase()) && !skip.contains(f.name.toLowerCase())) f,
  ]..sort((a, b) {
      final at = a.latestAt, bt = b.latestAt;
      if (at == null && bt == null) return a.name.compareTo(b.name);
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
  if (fresh.isEmpty) return existing;

  final usedNames = {for (final a in existing) a.displayName.toLowerCase()};
  var order = existing.isEmpty ? 0 : existing.map((a) => a.sortOrder).reduce((x, y) => x > y ? x : y) + 1;
  var toActivate = activateRecent;
  final added = <Album>[];
  for (var i = 0; i < fresh.length; i++) {
    final f = fresh[i];
    var display = f.name;
    // Keep display names unique (V4), e.g. two "Camera" buckets elsewhere.
    var n = 2;
    while (usedNames.contains(display.toLowerCase())) {
      display = '${f.name} ($n)';
      n++;
    }
    usedNames.add(display.toLowerCase());
    final activate = toActivate > 0 && !kSystemFolderNames.contains(f.name);
    if (activate) toActivate--;
    added.add(Album(
      id: 'g${now.microsecondsSinceEpoch}_$i',
      folderName: f.name,
      displayName: display,
      isVisible: activate,
      sortOrder: order++,
      createdAt: now,
      relativePath: f.relativePath,
      isImported: true,
    ));
  }
  return [...existing, ...added];
}
