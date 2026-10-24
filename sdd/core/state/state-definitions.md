---
title: State Definitions
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# State Definitions

Shape of state shared across features. Implementation (e.g. Bloc/Riverpod/Provider) is a
`fe/` or infra concern; this document defines shape and transitions only.

## PermissionState
`unrequested → granted | denied`
- Two independent instances: camera permission, photo-library permission (§7).
- `denied` has a recovery path: rationale → deep-link to system Settings → re-check on
  app resume. See [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md).

## AppLaunchState
`firstRun | returning`
- Backed by `AppSettings.hasCompletedOnboarding` (§15).
- `firstRun`: run full permission + recent-album flow (§7).
- `returning`: skip directly to main camera screen with Initial Album Focus applied (DR-7 — the
  last-used album, per its capture-only update trigger).

## AlbumLoopState
- `visibleAlbums: Album[]` — albums with `isVisibleInLoop = true`, excluding system albums by default (DR-2).
- `selectedIndex` / `currentAlbum` — the album that is both displayed centered and the
  active save target. Never a hidden album (DR-11).
- Transitions: swipe/tap moves `selectedIndex`; loop wraps (infinite carousel, DR-6).
- **Reselection transition (DR-12):** if the album management surface hides the current
  `currentAlbum`, `AlbumLoopState` immediately re-resolves `currentAlbum` using the same rule
  as Initial Album Focus (DR-7), scoped to the now-current `visibleAlbums`. This is the same
  resolution logic invoked at two different triggers (launch, visibility-change), not two
  separate rules.
- **Empty state (DR-13):** if `visibleAlbums` is empty, `currentAlbum` is `null`; the shutter
  is disabled and the loop area shows a create/unhide prompt rather than an empty carousel.

## CaptureState
`idle → capturing → success | failure`
- `success`: triggers save (see [feature/album/save-flow.md](../../feature/album/save-flow.md)) and
  brief visual feedback only — no preview state exists in MVP (§11).
- `failure`: triggers error modal; returns to `idle` on user confirmation, camera screen
  remains mounted (§12).

## ModalState
`none | newAlbumModal | manageAlbumModal | settingsModal`
- Mutually exclusive; dismiss returns to `none` without altering `AlbumLoopState` unless
  the modal action explicitly changes it (create / show-hide — rename is excluded, DR-8).
- `manageAlbumModal` is the single entry point for both album creation (opens `newAlbumModal`
  on top) and visibility management — see [feature/album/manage-album.md](../../feature/album/manage-album.md).
- `settingsModal` holds no album-lifecycle or camera-runtime state; it reads/writes
  `AppSettings` only (see [feature/settings/overview.md](../../feature/settings/overview.md)).
  Per [architecture/navigation_strategy.md](../../../architecture/navigation_strategy.md),
  Settings is a modal like the other two, not a routed screen.
