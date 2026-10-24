import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories/camera_repository.dart';
import '../domain/repositories/gallery_repository.dart';
import '../domain/repositories/permission_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../../features/camera_album/data/camera_repository_impl.dart';
import '../../features/camera_album/data/gallery_repository_impl.dart';
import '../../features/camera_album/data/permission_repository_impl.dart';
import '../../features/camera_album/data/settings_repository_impl.dart';

part 'repository_providers.g.dart';

/// Root composition — binds domain interfaces to data/ implementations as
/// app-wide singletons. See architecture/dependency_injection.md ("Root DI").

@Riverpod(keepAlive: true)
CameraRepository cameraRepository(CameraRepositoryRef ref) => CameraRepositoryImpl();

@Riverpod(keepAlive: true)
GalleryRepository galleryRepository(GalleryRepositoryRef ref) => GalleryRepositoryImpl();

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(PermissionRepositoryRef ref) => PermissionRepositoryImpl();

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) => SettingsRepositoryImpl();
