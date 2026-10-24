---
title: Infra — Permission Handling
category: infra
status: mvp
owner: infra
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Permission Handling

## Plugin Decision (Locked)
`permission_handler` is the locked choice (confirmed via technical spike: actively
maintained, dominant community adoption, supports `openAppSettings()` deep-link recovery
on both platforms).

## Required Permissions (§16, confirmed via technical spike)
- **Camera** (both platforms).
- **Android:** if the app only reads/writes MediaStore entries it created itself, no
  runtime permission is required under scoped storage. `READ_MEDIA_IMAGES` (Android 13+)
  is needed specifically to enumerate/read albums the app didn't create (required here,
  since the album loop shows existing user albums). Android 14 adds
  `READ_MEDIA_VISUAL_USER_SELECTED` for partial/limited access.
- **iOS:** `NSCameraUsageDescription` plus full `NSPhotoLibraryUsageDescription` (not the
  narrower add-only variant, since the app must enumerate existing albums, not just add
  photos). iOS 14+ Limited Photo Library Access may restrict the enumerable album set —
  see [`sdd/feature/album/album-definition.md`](../../feature/album/album-definition.md).

## Request Sequencing (§7)
Camera permission is requested before photo access permission on first run. See
[feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md) for the
user-facing flow this powers.

## Platform-Level Mechanics
- Detect current permission state (`unrequested | granted | denied`) per
  [core/state/state-definitions.md](../../core/state/state-definitions.md) `PermissionState`.
- On denial, provide a deep link into system Settings (both camera and photo-access cases).
- Re-check permission state when the app resumes from background (covers the
  Settings-round-trip recovery path in §7).

## Related Specs
- [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md)
- [core/state/state-definitions.md](../../core/state/state-definitions.md)
- [infra/platform/platform-support.md](../platform/platform-support.md) — per-OS permission API differences
