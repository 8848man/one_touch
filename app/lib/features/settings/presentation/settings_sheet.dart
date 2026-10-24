import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_info_provider.dart';

/// Settings — sdd/feature/settings/overview.md. Global application
/// preferences only; never camera runtime controls or album lifecycle
/// (architecture/feature_guidelines.md's `settings` section). MVP content is
/// intentionally minimal: About, App Version, OSS License, and an
/// informational (non-configurable) Initial Album Focus item. Presented as a
/// modal, consistent with architecture/navigation_strategy.md — no routing
/// package, no dedicated screen route.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(
              title: Text('About'),
              subtitle: Text('One-Touch Camera — album-swipe camera: pick the destination '
                  'album before shooting, so capture and organization happen in one action.'),
            ),
            ListTile(
              title: const Text('App Version'),
              subtitle: appInfoAsync.when(
                loading: () => const Text('Loading…'),
                error: (e, st) => const Text('Unavailable'),
                data: (info) => Text('${info.version} (${info.buildNumber})'),
              ),
            ),
            ListTile(
              title: const Text('Open Source Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'One-Touch Camera',
                applicationVersion: appInfoAsync.valueOrNull?.version,
              ),
            ),
            // Informational only — not a toggle. Initial Album Focus has
            // exactly one MVP behavior (DR-7); a setting with one option
            // isn't a setting. See sdd/feature/settings/overview.md.
            const ListTile(
              title: Text('Initial Album Focus'),
              subtitle: Text('Last Used Album'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
