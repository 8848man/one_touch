import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album_rules.dart';
import '../../../design_system/design_system.dart';
import '../application/settings_providers.dart';
import 'plans_sheet.dart';

/// Settings (screens.md §5). Global preferences only — no camera controls,
/// no album lifecycle (sdd/feature/settings/overview.md boundary).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _dataNotice = '사진과 동영상은 기기 갤러리의 Pictures 폴더에 저장돼요. '
      '앱을 지워도 사진은 남고, 앨범 목록·순서·표시 설정만 지워져요.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';

    void info(String title, String message) {
      showDialog<void>(
        context: context,
        barrierColor: AppColors.scrim,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message, style: AppText.body),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _Section('요금제'),
          ListTile(
            title: const Text('요금제 안내'),
            subtitle: Text(premium ? '프리미엄 체험 중' : '무료 · 앨범 $kFreeActiveAlbumLimit개까지 켜기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showPlansSheet(context),
          ),
          SwitchListTile(
            title: const Text('프리미엄 체험 (테스트)'),
            subtitle: const Text('결제 없이 앨범 수 제한을 풀어요'),
            value: premium,
            onChanged: (v) => ref.read(premiumProvider.notifier).setPremium(v),
          ),
          const _Section('앱'),
          ListTile(title: const Text('앱 정보'), trailing: Text(version, style: AppText.caption)),
          ListTile(
            title: const Text('이용약관'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => info('이용약관', '준비 중이에요.'),
          ),
          ListTile(
            title: const Text('문의하기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => info('문의하기', '문의 채널은 준비 중이에요.'),
          ),
          ListTile(
            title: const Text('데이터 안내'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => info('데이터 안내', _dataNotice),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.s),
      child: Text(label, style: AppText.label.copyWith(color: AppColors.primary)),
    );
  }
}
