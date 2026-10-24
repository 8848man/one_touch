import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  @override
  Future<bool> requestCameraAndPhotoAccess() async {
    // Camera first, then photo access — sdd/feature/onboarding/first-run-flow.md.
    final cameraStatus = await Permission.camera.request();
    final photoState = await PhotoManager.requestPermissionExtend();
    return cameraStatus == PermissionStatus.granted && photoState.hasAccess;
  }
}
