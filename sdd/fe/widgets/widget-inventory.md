---
title: Widget Inventory
category: fe
status: mvp
owner: fe
version: 1.0
source:
  - camera.html
---

# Widget Inventory

Reusable component concepts observed in the UI reference (camera.html). Names here are
conceptual, not final Flutter class names.

| Widget | Description | Used in |
|---|---|---|
| `CircleIconButton` | Circular, blurred-backdrop icon button (flip, settings) | [main-camera-screen.md](../ui/main-camera-screen.md) |
| `AlbumPill` | Rounded pill showing current album name + icon | [main-camera-screen.md](../ui/main-camera-screen.md) |
| `ShutterPin` | Custom pin/teardrop-shaped shutter control, floats above the reel | [main-camera-screen.md](../ui/main-camera-screen.md), [feature/camera/shooting-flow.md](../../feature/camera/shooting-flow.md) |
| `AlbumReel` | Horizontally scrollable, infinite-loop carousel of album chips | [main-camera-screen.md](../ui/main-camera-screen.md), [feature/album/album-loop.md](../../feature/album/album-loop.md) |
| `AlbumChip` | Single album name entry within the reel, with distance-based styling | [interaction-patterns.md](../ux/interaction-patterns.md) |
| `ActionButton` | Rounded rectangular button with icon + label — single instance on the Main Camera Screen ("Album", opens Album Management; sole entry point, also reached for album creation) | [main-camera-screen.md](../ui/main-camera-screen.md) |
| `ModalOverlay` | Dimmed/blurred backdrop + centered panel container | [new-album-modal.md](../ui/new-album-modal.md), [manage-album-modal.md](../ui/manage-album-modal.md) |
| `ToggleSwitch` | Binary on/off control with sliding thumb | [manage-album-modal.md](../ui/manage-album-modal.md) |
| `FlashOverlay` | Full-screen transient flash effect on capture | [interaction-patterns.md](../ux/interaction-patterns.md) |
| `SavedTag` | Transient pulse label confirming save destination | [interaction-patterns.md](../ux/interaction-patterns.md) |

## Related Specs
- [fe/ui/main-camera-screen.md](../ui/main-camera-screen.md)
- [fe/ux/interaction-patterns.md](../ux/interaction-patterns.md)
