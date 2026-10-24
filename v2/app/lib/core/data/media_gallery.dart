import 'dart:io';

import 'package:flutter/services.dart';

import 'package:photo_manager/photo_manager.dart';

import '../domain/album_rules.dart';

enum MoveStatus {
  /// Every asset now lives in the target folder.
  moved,

  /// Nothing to move.
  empty,

  /// The user declined the system confirmation, or the write failed.
  denied,

  /// Android 10 and below: MediaStore cannot move other apps' files.
  unsupported,
}

class MoveOutcome {
  const MoveOutcome(this.status, [this.count = 0]);

  final MoveStatus status;
  final int count;

  bool get changed => status == MoveStatus.moved || status == MoveStatus.empty;
}

/// Result of [MediaGallery.trash].
class TrashOutcome {
  const TrashOutcome(this.count, {this.unsupported = false});

  /// Items moved to the trash (0 when the user cancelled).
  final int count;

  /// Android 10 and below: there is no system trash, nothing was changed.
  final bool unsupported;
}

/// Device gallery access via photo_manager. Ported from the MVP
/// gallery_repository_impl.dart: `relativePath` creates the MediaStore folder
/// on the first write and reuses it afterwards (validated in the MVP spike).
class MediaGallery {
  static String _stamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// Saves into [relativePath]; if that folder is not writable for this app
  /// (e.g. another app's private media folder), retries in [fallbackPath]
  /// (sdd_v2 V17 / R3).
  Future<void> saveImage(String filePath, {required String relativePath, required String fallbackPath}) {
    return _withFallback(
      relativePath,
      fallbackPath,
      (path) => PhotoManager.editor.saveImageWithPath(
        filePath,
        title: 'IMG_${_stamp()}.jpg',
        relativePath: path,
      ),
    );
  }

  Future<void> saveVideo(String filePath, {required String relativePath, required String fallbackPath}) {
    return _withFallback(
      relativePath,
      fallbackPath,
      (path) => PhotoManager.editor.saveVideo(
        File(filePath),
        title: 'VID_${_stamp()}.mp4',
        relativePath: path,
      ),
    );
  }

  Future<void> _withFallback(String primary, String fallback, Future<Object?> Function(String path) save) async {
    try {
      await save(primary);
    } catch (_) {
      if (_samePath(primary, fallback)) rethrow;
      await save(fallback);
    }
  }

  static bool _samePath(String a, String b) {
    String norm(String p) => p.endsWith('/') ? p.substring(0, p.length - 1) : p;
    return norm(a).toLowerCase() == norm(b).toLowerCase();
  }

  Future<List<AssetPathEntity>> _paths() async {
    try {
      return await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: false,
        filterOption: FilterOptionGroup(
          orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
        ),
      );
    } catch (_) {
      return const [];
    }
  }

  /// Photo + video count per folder name. Several MediaStore buckets with the
  /// same name are summed.
  Future<Map<String, int>> countByFolder() async {
    final counts = <String, int>{};
    for (final path in await _paths()) {
      final count = await path.assetCountAsync;
      counts.update(path.name, (c) => c + count, ifAbsent: () => count);
    }
    return counts;
  }

  /// Every non-empty gallery folder with its newest item (sdd_v2 V15). Buckets
  /// that share a name are merged; the newest one decides the save path.
  Future<List<GalleryFolder>> scanFolders() async {
    final byName = <String, GalleryFolder>{};
    for (final path in await _paths()) {
      final count = await path.assetCountAsync;
      if (count == 0) continue;
      AssetEntity? newest;
      try {
        final first = await path.getAssetListRange(start: 0, end: 1);
        newest = first.isEmpty ? null : first.first;
      } catch (_) {
        newest = null;
      }
      final latestAt = newest?.createDateTime;
      final relativePath = _usableRelativePath(newest?.relativePath);
      final previous = byName[path.name];
      if (previous == null) {
        byName[path.name] = GalleryFolder(
          name: path.name,
          count: count,
          relativePath: relativePath,
          latestAt: latestAt,
        );
      } else {
        final newer = latestAt != null && (previous.latestAt == null || latestAt.isAfter(previous.latestAt!));
        byName[path.name] = GalleryFolder(
          name: path.name,
          count: previous.count + count,
          relativePath: newer ? relativePath : previous.relativePath,
          latestAt: newer ? latestAt : previous.latestAt,
        );
      }
    }
    return byName.values.toList();
  }

  /// Android 10+ reports e.g. `DCIM/Camera/`; Android 9 and below report an
  /// absolute directory, which MediaStore cannot take as a relative path.
  static String? _usableRelativePath(String? path) {
    if (path == null || path.isEmpty || path.startsWith('/')) return null;
    return path;
  }

  /// Newest-first media in [folderName], capped at [limit].
  Future<List<AssetEntity>> list(String folderName, {int limit = 300}) async {
    final result = <AssetEntity>[];
    for (final path in await _paths()) {
      if (path.name != folderName) continue;
      final count = await path.assetCountAsync;
      if (count == 0) continue;
      result.addAll(await path.getAssetListRange(start: 0, end: count < limit ? count : limit));
    }
    result.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    return result.length > limit ? result.sublist(0, limit) : result;
  }

  Future<AssetEntity?> latest(String folderName) async {
    final items = await list(folderName, limit: 1);
    return items.isEmpty ? null : items.first;
  }

  /// `Pictures/Trip` → `Pictures/Trip/` (MediaStore RELATIVE_PATH form).
  static String asDir(String path) => path.endsWith('/') ? path : '$path/';

  /// `DCIM/Camera/` + `Trip` → `DCIM/Trip/` (same parent, new folder name).
  static String siblingPath(String savePath, String folderName) {
    final trimmed = savePath.endsWith('/') ? savePath.substring(0, savePath.length - 1) : savePath;
    final slash = trimmed.lastIndexOf('/');
    final parent = slash < 0 ? 'Pictures' : trimmed.substring(0, slash);
    return '$parent/$folderName/';
  }

  /// Moves [assets] into [targetPath] by rewriting their RELATIVE_PATH.
  /// Android 11+ shows one system confirmation for the whole batch.
  Future<MoveOutcome> moveAssets(List<AssetEntity> assets, String targetPath) async {
    if (assets.isEmpty) return const MoveOutcome(MoveStatus.empty);
    try {
      final ok = await PhotoManager.editor.android.moveAssetsToPath(entities: assets, targetPath: asDir(targetPath));
      return ok ? MoveOutcome(MoveStatus.moved, assets.length) : const MoveOutcome(MoveStatus.denied);
    } on PlatformException catch (e) {
      final text = '${e.code} ${e.message}';
      if (text.contains('Android 11') || text.contains('API 30')) return const MoveOutcome(MoveStatus.unsupported);
      return const MoveOutcome(MoveStatus.denied);
    } catch (_) {
      return const MoveOutcome(MoveStatus.denied);
    }
  }

  /// Renames a gallery folder: Android has no folder rename, so every photo
  /// and video of [folderName] is moved to [targetPath] (sdd_v2 V7).
  Future<MoveOutcome> moveFolder(String folderName, String targetPath) async {
    return moveAssets(await list(folderName, limit: 1 << 30), targetPath);
  }

  /// Moves [assets] to the system trash (Android 11+, restorable for 30
  /// days; the system asks for confirmation).
  Future<TrashOutcome> trash(List<AssetEntity> assets) async {
    if (assets.isEmpty) return const TrashOutcome(0);
    try {
      final ids = await PhotoManager.editor.android.moveToTrash(assets);
      return TrashOutcome(ids.length);
    } on PlatformException catch (e) {
      if ('${e.code} ${e.message}'.contains('29 or lower')) return const TrashOutcome(0, unsupported: true);
      rethrow;
    }
  }

  /// Permanent delete, for Android 10 and below where there is no trash.
  Future<int> deletePermanently(List<AssetEntity> assets) async {
    final ids = await PhotoManager.editor.deleteWithIds([for (final a in assets) a.id]);
    return ids.length;
  }
}
