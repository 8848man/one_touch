---
title: Repository Pattern
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/infra/
---

# Repository Pattern

## Purpose
Isolate plugin/platform detail (`camera`, `photo_manager`, `permission_handler`,
`shared_preferences`) behind `domain/`-owned interfaces, so `presentation/` and `domain/`
never know which plugin — or which fallback — is in use.

## Interfaces (domain) vs Implementations (data)
| Interface (domain) | Implementation (data) | Wraps |
|---|---|---|
| `AlbumRepository` | `AlbumRepositoryImpl` | `photo_manager` |
| `PhotoRepository` | `PhotoRepositoryImpl` | `photo_manager` (save/create/copy) |
| `CameraRepository` | `CameraRepositoryImpl` | `camera` plugin |
| `PermissionRepository` | `PermissionRepositoryImpl` | `permission_handler` |
| `SettingsRepository` | `SettingsRepositoryImpl` | `shared_preferences` |

`AlbumRepository` and `PhotoRepository` interfaces live in `core/domain/repositories/`
(shared kernel, per [folder_structure.md](folder_structure.md)); `CameraRepository` and
`PermissionRepository` are feature-owned (camera, onboarding respectively) since no other
feature needs them.

## Fallback Path (from the technical spike)
The spike report flagged unverified reliability of `photo_manager`'s `copyAssetToPath`
across Android OEMs, and unverified EXIF preservation. If a device-level validation spike
finds these unreliable, the fallback is a native-channel implementation of
`PhotoRepositoryImpl` (direct `MediaStore`/`PHPhotoLibrary` calls) — swapped in `data/`
only. `domain/` and `presentation/` require no changes for this fallback. See
[`sdd/infra/storage/gallery-storage-strategy.md`](../sdd/infra/storage/gallery-storage-strategy.md).

## Mapping Rule
Repository implementations must map plugin-native types (`AssetPathEntity`, platform
permission enums, etc.) to domain entities (`Album`, `Photo`) before returning them —
plugin types never cross into `domain/` or `presentation/`.

## Related Documents
- [dependency_rules.md](dependency_rules.md)
- [folder_structure.md](folder_structure.md)
