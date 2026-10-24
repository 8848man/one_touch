import 'package:flutter/material.dart';

import '../../../core/domain/album_rules.dart';
import '../../../design_system/tokens.dart';

/// 요금제 안내 (scope.md O4). Informational only — no payment in the prototype.
Future<void> showPlansSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text('요금제 안내', style: AppText.title),
            SizedBox(height: AppSpace.l),
            _PlanCard(title: '무료', description: '앨범을 $kFreeActiveAlbumLimit개까지 켜 두고 쓸 수 있어요.'),
            SizedBox(height: AppSpace.m),
            _PlanCard(
              title: '프리미엄',
              description: '켜 둘 수 있는 앨범 수에 제한이 없어요.\n결제는 준비 중이에요. 설정의 "프리미엄 체험"으로 미리 써 보세요.',
              highlighted: true,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.description, this.highlighted = false});

  final String title;
  final String description;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryTint : AppColors.surface,
        border: Border.all(color: highlighted ? AppColors.primary : AppColors.switchOffTrack),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpace.xs),
          Text(description, style: AppText.label.copyWith(color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}
