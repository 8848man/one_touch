---
title: Infra — Gallery Storage Strategy
category: infra
status: mvp
owner: infra
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Gallery Storage Strategy

## Status: Spike Complete, Strategy Locked
The technical spike (§5) is complete. `photo_manager` is the locked plugin choice for
album enumeration, creation, and photo save.

## Confirmed Strategy
Neither platform supports a true single-call "create photo directly inside album X."
The confirmed pattern is a two-step create-then-attach, treated as atomic from the
feature layer's perspective (see [`architecture/repository_pattern.md`](../../../architecture/repository_pattern.md)):
- **Android:** `MediaStore.insert()` with `RELATIVE_PATH`/`DISPLAY_NAME` (no
  `WRITE_EXTERNAL_STORAGE` needed for the app's own entries under scoped storage).
- **iOS:** `PHAssetCreationRequest` (create) + `PHAssetCollectionChangeRequest.addAssets()`
  (attach), both inside one `performChanges` transaction.

Album creation follows the Pending Album state machine (DR-9) on Android; iOS creates
immediately via `photo_manager`'s `createAlbum()`.

## Remaining Open Items (require a device-level code spike, not just this document)
- **EXIF preservation** through `photo_manager`'s save/copy path is not confirmed by
  documentation — needs an actual device test.
- **Cross-OEM reliability** of `copyAssetToPath` targeting a pre-existing folder (tested
  docs-only; recommend validating on at least Samsung/Pixel/Xiaomi before relying on it
  in `feature/album/save-flow.md`'s implementation).
- **Fallback**, if either of the above fails: native platform-channel implementation of
  `PhotoRepositoryImpl`, bypassing `photo_manager` for the save path only — swappable
  without touching `domain/` or `presentation/` (see
  [`architecture/repository_pattern.md`](../../../architecture/repository_pattern.md)).

## Rename — Not Applicable to This Strategy
Album rename is excluded from MVP (DR-8) specifically because no viable strategy — via
`photo_manager` or native APIs — exists for Android without a risky folder-rename/consent
flow. This document does not propose one.

## Related Specs
- [feature/album/album-definition.md](../../feature/album/album-definition.md) — DR-1/DR-2/DR-3 constraints this strategy must satisfy
- [feature/album/create-album.md](../../feature/album/create-album.md)
- [feature/album/save-flow.md](../../feature/album/save-flow.md) — failure modes this strategy can produce
- [infra/platform/platform-support.md](../platform/platform-support.md)
