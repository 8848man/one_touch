---
title: Riverpod + MVVM Rules
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/core/state/state-definitions.md
---

# Riverpod + MVVM Rules

## Core Rule
Each screen owns exactly one ViewModel. Widgets read state from the ViewModel via
Riverpod providers; they never call a UseCase or repository directly.

```
Widget → (reads) → ViewModel (Riverpod Notifier) → UseCase → Repository interface
```

## Screen-to-ViewModel Mapping (MVP)
| Screen/surface | ViewModel |
|---|---|
| Main camera screen | `CameraViewModel` |
| New album modal | `NewAlbumViewModel` |
| Manage album modal | `ManageAlbumViewModel` |

Onboarding has no ViewModel of its own screen-wise (see
[feature_guidelines.md](feature_guidelines.md)) — its permission-flow state is exposed to
`CameraViewModel` during initialization.

## State Shape
ViewModels expose state shaped by
[`sdd/core/state/state-definitions.md`](../sdd/core/state/state-definitions.md):
`PermissionState`, `AppLaunchState`, `AlbumLoopState`, `CaptureState`, `ModalState`. Do not
invent new top-level state categories without updating that spec first.

## Illustrative Pattern (not production code)
```dart
class CameraViewModel extends Notifier<CameraUiState> {
  @override
  CameraUiState build() => CameraUiState.initial();

  Future<void> onShutterTapped() async {
    final result = await ref.read(captureAndSaveUseCaseProvider).execute(
      albumId: state.albumLoop.currentAlbum.id,
    );
    state = state.copyWith(captureState: result.toCaptureState());
  }
}
```

## Rules
1. A ViewModel never imports `data/` or any plugin package — only `domain/` UseCases.
2. A ViewModel never exposes repository or plugin-native types — only UI-facing state
   objects.
3. Widgets never call `ref.read(someRepositoryProvider)` directly — only the owning
   ViewModel's provider.
4. Provider scoping: feature-local providers live in that feature's `di/`; the
   `CameraViewModel`'s provider is defined in `features/camera/di/`, not in `core/` or root `di/`.

## Related Documents
- [state_management.md](state_management.md)
- [dependency_injection.md](dependency_injection.md)
