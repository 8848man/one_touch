---
title: Screen Specifications (Reference Map)
category: screen_ref
status: mvp
owner: screen_ref
version: 1.0
source:
  - camera.html
  - one_touch_plan_doc.pdf
---

# Screen Specifications

Maps each visual reference to its business (`feature/`) and implementation (`fe/`) specs.
This document itself carries no business rules and no implementation detail.

## Main Camera Screen
- **Purpose:** primary screen; live preview, album loop, shutter (§8).
- **Business spec:** [feature/camera/overview.md](../feature/camera/overview.md),
  [feature/album/overview.md](../feature/album/overview.md)
- **Implementation spec:** [fe/ui/main-camera-screen.md](../fe/ui/main-camera-screen.md)
- **Visual reference:** [screen_ref/html/camera.html](html/camera.html)

## New Album Modal
- **Purpose:** create a new destination album (§13). Entry point revised — opened from
  within Album Management, not a standalone camera-screen button (see Manage Album Modal
  below and [feature/album/create-album.md](../feature/album/create-album.md)).
- **Business spec:** [feature/album/create-album.md](../feature/album/create-album.md)
- **Implementation spec:** [fe/ui/new-album-modal.md](../fe/ui/new-album-modal.md)
- **Visual reference:** [screen_ref/html/camera.html](html/camera.html) (`#newOverlay`)

## Manage Album Modal (Album Management)
- **Purpose:** toggle album loop visibility (show/hide) and serve as the sole entry point
  for album creation. **Rename is excluded from MVP (DR-8)** — the §14 reference to renaming
  albums does not apply; do not treat this visual reference's rename UI as current spec.
- **Business spec:** [feature/album/manage-album.md](../feature/album/manage-album.md)
- **Implementation spec:** [fe/ui/manage-album-modal.md](../fe/ui/manage-album-modal.md)
- **Visual reference:** [screen_ref/html/camera.html](html/camera.html) (`#manageOverlay`) —
  reference only; its rename controls are superseded by DR-8.

## Settings Modal
- **Purpose:** global application preferences (About/app info for MVP). No visual reference
  exists yet — this is new MVP scope not present in the original `camera.html` prototype.
- **Business spec:** [feature/settings/overview.md](../feature/settings/overview.md)
- **Implementation spec:** none yet — MVP content is minimal enough that `fe/ui/` composition
  detail lives directly in the business spec; split out if roadmap-v1.1 content grows it.
- **Visual reference:** none yet.

## Navigation Between Screens
See [fe/navigation/navigation-map.md](../fe/navigation/navigation-map.md).

## Asset Status
| Asset type | Status |
|---|---|
| HTML prototype | Present — [html/camera.html](html/camera.html) |
| Mockups | None yet — see [mockup/README.md](mockup/README.md) |
| Wireframes | None yet — see [wireframe/README.md](wireframe/README.md) |
| Screenshots | None yet — see [screenshots/README.md](screenshots/README.md) |
