---
title: UI — Main Camera Screen
category: fe
status: mvp
owner: fe
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Main Camera Screen

Implements the behavior defined in [feature/camera/overview.md](../../feature/camera/overview.md)
and [feature/album/overview.md](../../feature/album/overview.md). This document describes
composition only — business rules are not redefined here.

**Ownership note:** the carousel/reel is visually hosted on this screen but owned by the
Album feature (not Camera) — see `architecture/feature_guidelines.md`. This screen's
responsibility ends at displaying the current selection and hosting the entry points below;
it performs no album lifecycle logic itself.

## Layout (§8, cross-checked against camera.html; revised — see Regions table for what changed)

```
┌─────────────────────────────────┐
│ [flip]      [album pill]  [⚙]   │  ← top bar
│                                  │
│         live camera preview     │  ← full-bleed viewfinder
│                                  │
│              (pin shutter)      │  ← floating above loop
│  ‹  [ alb ][ alb ][ALBUM][alb][alb]  ›  │  ← album loop / reel
│         hint text                │
│           [Album]                │  ← bottom action (single entry point)
└─────────────────────────────────┘
```

## Regions
| Region | Contents | Source |
|---|---|---|
| Top-left | Front/back flip icon button | §8 |
| Top-center | Selected album name pill, e.g. `[ 부산여행 ]` | §8 |
| Top-right | Settings icon button — now functional, opens `settingsModal` | §8 (presence); [feature/settings/overview.md](../../feature/settings/overview.md) (contents, resolved) |
| Center | Live camera preview | §8 |
| Floating shutter | Pin-shaped control above the reel, doubles as capture trigger; disabled in the empty-loop state (DR-13) | camera.html, §8 |
| Reel | Horizontally scrollable album carousel with prev/next arrows; hosted here, owned by the Album feature | §8, §9, camera.html |
| Hint text | Short instructional caption below reel | camera.html (**Assumption:** exact copy is prototype-only, not PDF-specified) |
| Bottom action | "Album" button (was "앨범 관리") → opens Album Management (`manageAlbumModal`) — sole entry point for both listing/visibility and album creation | §8, §14; entry-point revised per [feature/album/manage-album.md](../../feature/album/manage-album.md) and [feature/album/create-album.md](../../feature/album/create-album.md) |

**Removed from this screen:** the standalone "새 앨범" (create album) action previously at
bottom-right. Album creation now has a single entry point inside Album Management — see
[feature/album/create-album.md](../../feature/album/create-album.md) for the rationale. This
is a deliberate deviation from §13's literal bottom-right-button placement (a UI-layout
detail, not a business rule).

## Related Specs
- [fe/widgets/widget-inventory.md](../widgets/widget-inventory.md) — reusable component definitions
- [fe/ux/interaction-patterns.md](../ux/interaction-patterns.md) — animation/motion detail
- [feature/settings/overview.md](../../feature/settings/overview.md) — top-right icon's resolved contents
- [screen_ref/screen-specifications.md](../../screen_ref/screen-specifications.md) — visual source mapping
