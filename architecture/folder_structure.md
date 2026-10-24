---
title: Folder Structure
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/feature/
---

# Folder Structure

## Full Tree

```
lib/
├── main.dart
├── core/                          # shared kernel — see flutter_architecture.md
│   ├── domain/
│   │   ├── entities/              # Album, Photo, AppSettings (see sdd/core/data/data-model.md)
│   │   └── repositories/          # AlbumRepository, PhotoRepository, SettingsRepository (interfaces)
│   └── state/                     # shared state shapes (see sdd/core/state/state-definitions.md)
│
├── common/                        # reusable presentation-layer widgets only — never domain/data
│   └── widgets/                   # CircleIconButton, ActionButton, ModalOverlay, ToggleSwitch, ...
│                                   # (see sdd/fe/widgets/widget-inventory.md)
│
├── features/
│   ├── camera/
│   │   ├── presentation/          # CameraScreen, CameraViewModel, providers
│   │   ├── domain/                # CaptureUseCase — depends on core/domain repositories
│   │   ├── data/                  # CameraDataSource (wraps `camera` plugin)
│   │   └── di/                    # feature-local provider wiring
│   ├── album/
│   │   ├── presentation/          # AlbumLoopWidget, NewAlbumModal, ManageAlbumModal, ViewModels
│   │   ├── domain/                # CreateAlbumUseCase, ToggleVisibilityUseCase, SelectAlbumUseCase
│   │   ├── data/                  # AlbumRepositoryImpl (wraps `photo_manager`)
│   │   └── di/
│   ├── onboarding/
│   │   ├── presentation/          # permission-flow orchestration (no dedicated screen — see feature_guidelines.md)
│   │   ├── domain/                # RequestPermissionsUseCase
│   │   ├── data/                  # PermissionDataSource (wraps `permission_handler`)
│   │   └── di/
│   └── settings/                  # deliberately minimal — see feature_guidelines.md
│       ├── presentation/          # SettingsScreen, SettingsViewModel — reads/writes
│       │                          # core/domain's SettingsRepository directly
│       └── di/                    # exposes the ViewModel provider only
│                                   # (no domain/ or data/ — nothing settings-specific to isolate)
│
└── di/                            # root composition — app-wide singletons
    └── app_providers.dart         # binds core/domain repository interfaces to data/ implementations
```

## Placement Rules
- A type used by exactly one feature lives inside that feature's own `domain/`/`data/`.
- A type used by more than one feature (currently: `Album`, `Photo`, `AppSettings` and
  their repository interfaces) lives in `core/domain/` — never duplicated per-feature.
- Reusable **UI widgets** (no business logic) live in `common/widgets/`, distinct from
  `core/` (domain/state) — this separation prevents "common" from becoming a dumping
  ground for both UI and domain concerns.
- `features/onboarding` has no dedicated screen widget (per
  [`sdd/fe/navigation/navigation-map.md`](../sdd/fe/navigation/navigation-map.md)); its
  `presentation/` layer contains only the permission-request orchestration consumed by
  the camera feature's screen on first launch — see [feature_guidelines.md](feature_guidelines.md).
- `features/settings` has a dedicated screen (modal) but no `domain/`/`data/` — the inverse
  minimal-footprint shape from `onboarding`. It has UI but no business logic of its own; see
  [feature_guidelines.md](feature_guidelines.md).

## Related Documents
- [flutter_architecture.md](flutter_architecture.md)
- [dependency_rules.md](dependency_rules.md)
- [feature_guidelines.md](feature_guidelines.md)
