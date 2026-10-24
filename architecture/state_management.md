---
title: State Management
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/core/state/state-definitions.md
---

# State Management

## Single Solution
Riverpod is the only state-management mechanism in this codebase. Do not introduce a
second one (e.g. Provider, Bloc, GetX) for any feature.

## Mapping from SDD State Shapes
[`sdd/core/state/state-definitions.md`](../sdd/core/state/state-definitions.md) defines
state shape independent of implementation. This is the Riverpod realization of each:

| SDD state | Riverpod construct | Owner |
|---|---|---|
| `PermissionState` | `Notifier<PermissionState>` | `features/onboarding/di/` |
| `AppLaunchState` | `Notifier<AppLaunchState>`, backed by `core/domain`'s `SettingsRepository` | root `di/` (read by camera feature) |
| `AlbumLoopState` | `Notifier<AlbumLoopState>` | `features/album/di/` |
| `CaptureState` | Part of `CameraViewModel`'s state | `features/camera/di/` |
| `ModalState` | Part of `AlbumViewModel`'s (or a shared album-UI) state | `features/album/di/` |

## Rules
1. Riverpod providers are declared in the owning feature's `di/`, never inline in a widget.
2. State objects exposed by a ViewModel are UI-facing types, not domain entities or
   plugin-native types (see [repository_pattern.md](repository_pattern.md) for the
   mapping boundary).
3. Cross-feature state reads (e.g. camera reading the currently selected album) go
   through the shared `core/domain` repository, exposed via a root-level provider — not
   by one feature importing another feature's ViewModel.

## Related Documents
- [riverpod_mvvm.md](riverpod_mvvm.md)
- [dependency_injection.md](dependency_injection.md)
