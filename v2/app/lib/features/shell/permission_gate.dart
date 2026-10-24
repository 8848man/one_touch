import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../design_system/design_system.dart';

/// Shows [child] once camera + gallery access is granted (screens.md §0).
///
/// One in-app explanation screen, then the camera and photo system dialogs
/// back to back. The microphone is asked later, the first time video mode is
/// chosen (CameraNotifier.setMode). Android shows one system dialog per
/// permission group, so they cannot be merged into a single dialog.
class PermissionGate extends ConsumerStatefulWidget {
  const PermissionGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends ConsumerState<PermissionGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the system settings: pick up permissions granted there.
    if (state == AppLifecycleState.resumed) {
      final current = ref.read(permissionProvider).valueOrNull;
      if (current == null || !current.ready) ref.read(permissionProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionProvider);
    final snapshot = permission.valueOrNull;
    if (snapshot != null && snapshot.ready) return widget.child;
    if (snapshot == null && permission.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cameraSurface,
        body: Center(child: CircularProgressIndicator(color: AppColors.onCamera)),
      );
    }
    return const _PermissionIntro();
  }
}

class _PermissionIntro extends ConsumerStatefulWidget {
  const _PermissionIntro();

  @override
  ConsumerState<_PermissionIntro> createState() => _PermissionIntroState();
}

class _PermissionIntroState extends ConsumerState<_PermissionIntro> {
  bool _asked = false;
  bool _requesting = false;

  Future<void> _request() async {
    setState(() => _requesting = true);
    await ref.read(permissionProvider.notifier).requestEssentials();
    if (mounted) {
      setState(() {
        _requesting = false;
        _asked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.photo_camera_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpace.l),
              Text(
                '시작하려면 권한이 필요해요',
                style: AppText.title.copyWith(color: AppColors.onCamera),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.xl),
              const _PermissionRow(
                icon: Icons.photo_camera_outlined,
                title: '카메라',
                body: '사진과 동영상을 찍어요.',
              ),
              const _PermissionRow(
                icon: Icons.photo_library_outlined,
                title: '사진 및 동영상',
                body: '찍은 사진을 고른 앨범에 바로 저장하고, 기존 앨범을 불러와요.',
              ),
              const _PermissionRow(
                icon: Icons.mic_none,
                title: '마이크 (선택)',
                body: '동영상 모드를 처음 켤 때 물어봐요. 허용하지 않으면 소리 없이 녹화돼요.',
              ),
              const Spacer(),
              if (_asked)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.m),
                  child: Text(
                    '권한이 허용되지 않았어요. 다시 시도하거나 설정에서 직접 허용해 주세요.',
                    textAlign: TextAlign.center,
                    style: AppText.label.copyWith(color: AppColors.primarySoft),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _requesting ? null : _request,
                  child: Text(_asked ? '다시 시도' : '허용하고 시작하기'),
                ),
              ),
              if (_asked)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.onCamera),
                  onPressed: () => ref.read(permissionServiceProvider).openSettings(),
                  child: const Text('설정 열기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.onCamera, size: 22),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body.copyWith(color: AppColors.onCamera, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: AppText.label.copyWith(color: AppColors.onCameraMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
