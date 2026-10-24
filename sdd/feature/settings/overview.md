---
title: Settings Feature — Overview
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Settings — Overview

Settings is the global application-preference surface. It is deliberately not a business
feature in the sense `camera`/`album`/`onboarding` are — see
[architecture/feature_guidelines.md](../../../architecture/feature_guidelines.md) for its
minimal architectural footprint (presentation-only, no dedicated `domain/`/`data/`).

## Boundary (frozen product decision)
- Settings owns only global application preferences.
- Camera runtime controls (flash, camera flip, capture, carousel) never belong here — they
  remain on the Camera Screen. See [feature/camera/overview.md](../camera/overview.md) and
  [feature/camera/camera-settings.md](../camera/camera-settings.md).
- Album lifecycle (list, create, show/hide) never belongs here — it belongs to
  [feature/album/manage-album.md](../album/manage-album.md).

## Entry Point (§8)
Top-right settings icon on the Camera Screen. §8 confirms the icon's *presence*; this
document is the confirmed authority on its *contents* for MVP (superseding the "unconfirmed
scope" framing that previously applied to the icon generally — see
[feature/camera/camera-settings.md](../camera/camera-settings.md), which now covers only the
still-open ratio/timer question).

## MVP Content (Intentionally Minimal)
| Item | Notes |
|---|---|
| About / app info | Static content (version, credits). No PDF/SDD business rule governs its exact contents — treat as boilerplate. |

**This is intentional, not incomplete.** Initial Album Focus (DR-7) is a single fixed MVP
behavior with no alternative to choose between — a settings toggle with exactly one option
isn't a setting, so none is exposed here for MVP. See
[core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-7 for the terminology
distinction between "Initial Album Focus" (MVP, fixed) and "Album Focus Policy" (roadmap-v1.1,
user-selectable).

## Roadmap Content (`roadmap-v1.1`, not active in MVP)
- Album Focus Policy selector (Most-Used-Album, User-Pinned-Album alternatives) — this is the
  first genuinely configurable item Settings will gain, once those policies exist as real
  alternatives to compare against.

## Navigation
Settings is presented as a modal overlay, consistent with the other two MVP modals — see
[architecture/navigation_strategy.md](../../../architecture/navigation_strategy.md) and
[core/state/state-definitions.md](../../core/state/state-definitions.md) `ModalState`
(`settingsModal`). No routing package or dedicated route is introduced for this.

## Related Specs
- [architecture/feature_guidelines.md](../../../architecture/feature_guidelines.md) — architectural footprint
- [fe/ui/main-camera-screen.md](../../fe/ui/main-camera-screen.md) — entry-point composition
- [fe/navigation/navigation-map.md](../../fe/navigation/navigation-map.md)
