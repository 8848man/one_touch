import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/providers.dart';

/// "프리미엄 체험 (테스트)" switch — unlocks the free album limit (scope.md O4).
class PremiumNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(appPrefsProvider).premium;

  Future<void> setPremium(bool value) async {
    state = value;
    await ref.read(appPrefsProvider).setPremium(value);
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(PremiumNotifier.new);

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});
