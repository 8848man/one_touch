import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/providers.dart';

/// Photo+video count per device folder name (album list badge).
final mediaCountsProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.read(mediaGalleryProvider).countByFolder(),
);

/// Newest item of a folder (camera thumbnail).
final latestMediaProvider = FutureProvider.autoDispose.family<AssetEntity?, String>(
  (ref, folderName) => ref.read(mediaGalleryProvider).latest(folderName),
);

/// All items of a folder (album media grid).
final albumMediaProvider = FutureProvider.autoDispose.family<List<AssetEntity>, String>(
  (ref, folderName) => ref.read(mediaGalleryProvider).list(folderName),
);

/// Call after anything was written to the gallery.
void refreshMedia(Ref ref) {
  ref.invalidate(mediaCountsProvider);
  ref.invalidate(latestMediaProvider);
  ref.invalidate(albumMediaProvider);
}

/// Same as [refreshMedia], from a widget.
void refreshMediaFrom(WidgetRef ref) {
  ref.invalidate(mediaCountsProvider);
  ref.invalidate(latestMediaProvider);
  ref.invalidate(albumMediaProvider);
}
