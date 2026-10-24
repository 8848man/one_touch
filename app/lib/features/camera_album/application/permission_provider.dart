import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/application/repository_providers.dart';

part 'permission_provider.g.dart';

/// Resolves to true once camera+photo access is granted. UI gates on
/// this per architecture/riverpod_mvvm.md ("fail gracefully with UI state").
@riverpod
class PermissionStatusNotifier extends _$PermissionStatusNotifier {
  @override
  Future<bool> build() {
    return ref.read(permissionRepositoryProvider).requestCameraAndPhotoAccess();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(permissionRepositoryProvider).requestCameraAndPhotoAccess(),
    );
  }
}
