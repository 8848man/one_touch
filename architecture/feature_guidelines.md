---
title: Feature Guidelines
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/feature/
---

# Feature Guidelines

## General Rule
Each feature (`camera`, `album`, `onboarding`) is self-contained: its own
`presentation/domain/data/di`. Business flow and acceptance criteria for each feature are
defined in `sdd/feature/*` — this document covers only how those flows map to code
structure, not what the flows are.

`settings` is a deliberate, narrower exception — see its own section below. It ships in MVP
but is not a business feature in the same sense as the three above.

## camera
- Owns: live preview, shutter action, front/rear flip.
- Depends on `core/domain` for the currently-selected `Album` (does not own album
  selection logic itself — that belongs to `album`).
- See [`sdd/feature/camera/shooting-flow.md`](../sdd/feature/camera/shooting-flow.md).

## album
- Owns: the loop/carousel (visually hosted on the camera screen, but owned here — the
  camera feature never contains carousel logic), album creation (single entry point, inside
  Album Management — no separate camera-screen shortcut), album management (visibility
  toggle only — see Rename below), save-target selection, Initial Album Focus resolution
  (DR-7, DR-12; one shared UseCase invoked at both app-launch and visibility-change triggers).
- **Album creation state machine (locked):**
  ```
  Pending Album → user captures first photo → MediaStore album created → pending state removed
  ```
  This reflects a real Android platform constraint (no album exists until the first
  file lands in it — see the technical spike report). The `album` feature's domain layer
  must model a `PendingAlbum` state distinct from a persisted `Album`; only a persisted
  `Album` is a valid save target elsewhere in the app.
- **Album rename is excluded from MVP.** Do not implement any device-folder rename
  operation. See `sdd/feature/album/manage-album.md` for the updated spec — if the intent
  is later clarified to mean "in-app display name only, no folder touch," that would be a
  product-decision reopening, not an architecture change.
- See [`sdd/feature/album/create-album.md`](../sdd/feature/album/create-album.md),
  [`sdd/feature/album/manage-album.md`](../sdd/feature/album/manage-album.md).

## onboarding
- Owns: permission request sequencing only (camera → photo access → recent-album
  display). Has **no dedicated screen** — per
  [`sdd/fe/navigation/navigation-map.md`](../sdd/fe/navigation/navigation-map.md), the
  first-run flow happens against system permission dialogs, landing directly on the
  camera screen.
- Its `presentation/` layer exposes a ViewModel/controller consumed by the camera
  feature's screen during initialization, not a screen of its own.
- See [`sdd/feature/onboarding/first-run-flow.md`](../sdd/feature/onboarding/first-run-flow.md).

## settings
- **Not a business feature** in the sense the three above are — it owns no domain rules of
  its own and orchestrates no multi-step flow. It exists purely to display/edit
  `AppSettings` fields already owned by `core/domain`.
- Minimal footprint: `presentation/` only (a screen/ViewModel reading and writing
  `core/domain`'s `SettingsRepository` directly). No dedicated `domain/` or `data/` layer —
  there is no settings-specific business logic to house there, and no settings-specific
  plugin wrapper to isolate (it reads the same `SettingsRepository` `core/domain` already
  defines for `album`'s `DR-7` persistence).
- A thin `di/` may still exist purely to expose the screen's ViewModel provider, consuming
  the root-provided `SettingsRepository` — consistent with
  [`dependency_injection.md`](dependency_injection.md)'s feature-DI tier, just with nothing
  underneath it to wire besides that one repository read/write.
- See [`sdd/feature/settings/overview.md`](../sdd/feature/settings/overview.md).

## Cross-Feature Rule
If a UseCase needs data owned by another feature, it depends on `core/domain/`'s
repository interfaces, never on the other feature's `domain/` or `data/` directly.

## Related Documents
- [folder_structure.md](folder_structure.md)
- [dependency_rules.md](dependency_rules.md)
