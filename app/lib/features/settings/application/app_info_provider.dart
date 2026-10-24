import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_provider.g.dart';

/// Backs the App Version item in Settings — sdd/feature/settings/overview.md.
/// Thin, presentation-adjacent provider only; no domain/data layer of its
/// own, per architecture/feature_guidelines.md's `settings` section.
@riverpod
Future<PackageInfo> appInfo(AppInfoRef ref) => PackageInfo.fromPlatform();
