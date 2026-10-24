---
title: Infra — Camera Integration
category: infra
status: mvp
owner: infra
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Camera Integration

## Required Native Capabilities (§16)
- Camera permission and access.
- Live preview rendering (front and back sensors, §8 flip control).
- Capture trigger producing a still image file.

## Responsibilities
- Expose a capture API consumed by [feature/camera/shooting-flow.md](../../feature/camera/shooting-flow.md).
- Provide front/back sensor switching without interrupting active preview state.
- Hand off the captured image to the storage layer — see
  [infra/storage/gallery-storage-strategy.md](../storage/gallery-storage-strategy.md).

## Plugin Decision (Locked)
The official Flutter `camera` plugin is the locked choice (confirmed via technical spike:
actively maintained, official `flutter.dev` publisher, supports preview/capture/front-rear
switching). `image_picker`'s camera path was ruled out — it delegates to the OS's native
camera UI and cannot host this app's custom shutter/carousel interface.

**Lifecycle risk (confirmed):** since `camera` v0.5.0, the plugin no longer auto-manages
app lifecycle transitions. The app must explicitly dispose the `CameraController` on
`inactive`/`paused` and reinitialize on `resumed`, or the preview breaks on backgrounding.
This is required implementation work, not optional — see
[`architecture/repository_pattern.md`](../../../architecture/repository_pattern.md) for
where this is wrapped (`CameraRepositoryImpl`, `features/camera/data/`).

## Related Specs
- [feature/camera/shooting-flow.md](../../feature/camera/shooting-flow.md)
- [infra/platform/platform-support.md](../platform/platform-support.md)
