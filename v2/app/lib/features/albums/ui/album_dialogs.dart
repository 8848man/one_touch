import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album.dart';
import '../../../core/domain/album_rules.dart';
import '../../../design_system/design_system.dart';
import '../../settings/ui/plans_sheet.dart';
import '../application/albums_controller.dart';

/// "+" on the camera and the list's pill button both land here (screens.md §2, §6).
Future<Album?> showCreateAlbumFlow(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(albumsProvider.notifier);
  if (!notifier.canActivateMore) {
    await showFreeLimitDialog(context);
    return null;
  }
  final name = await showNameInputDialog(
    context,
    title: '새로운 앨범 추가',
    hint: '앨범 이름',
    maxLength: kMaxAlbumNameLength,
    validate: notifier.validateName,
  );
  if (name == null) return null;
  return notifier.create(name);
}

Future<void> showFreeLimitDialog(BuildContext context) async {
  final openPlans = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (ctx) => AlertDialog(
      title: const Text('구매가 필요해요'),
      content: const Text(
        '무료로는 앨범을 $kFreeActiveAlbumLimit개까지 켜 둘 수 있어요. 다른 앨범을 끄거나 요금제를 확인해 주세요.',
        style: AppText.body,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('닫기')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('요금제 보기')),
      ],
    ),
  );
  if (openPlans == true && context.mounted) await showPlansSheet(context);
}

Future<void> confirmDeleteAlbum(BuildContext context, WidgetRef ref, Album album) async {
  final confirmed = await showConfirmDialog(
    context,
    title: '앨범 삭제',
    message: '${album.displayName} 앨범을 삭제하시겠습니까?',
    note: '기기에 저장된 사진은 삭제되지 않아요.',
  );
  if (confirmed) await ref.read(albumsProvider.notifier).delete(album.id);
}

/// Switches an album on/off; shows the free-limit dialog when blocked (V13).
Future<void> toggleAlbumVisibility(BuildContext context, WidgetRef ref, Album album, bool visible) async {
  final ok = await ref.read(albumsProvider.notifier).setVisible(album.id, visible);
  if (!ok && context.mounted) await showFreeLimitDialog(context);
}
