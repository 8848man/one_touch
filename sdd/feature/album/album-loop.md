---
title: Album — Loop (Carousel Navigation)
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Album Loop

## Functional Flow (§8, §9)
- Albums are arranged in a horizontal loop; the centered album is the current save target
  and is displayed larger/emphasized than neighbors.
- Example ordering shown in PDF: 업무 ← 책 ← 부산여행 → 아이 → 기록.

## Interactions (§9)
| Interaction | Result |
|---|---|
| Swipe left/right | Move selection to neighboring album |
| Tap a non-centered album | That album becomes selected/centered |
| Tap the centered control | Triggers capture (see [feature/camera/shooting-flow.md](../camera/shooting-flow.md)), does not change selection |

## Behavior Rules
- No limit on number of albums in the loop (DR-6).
- Loop is structured as an infinite carousel (DR-6) — **this structure is explicitly
  subject to change post-MVP based on user feedback**, per the source document; do not
  treat "infinite loop" as a permanent architectural commitment.
- Selected album persists across app restarts via `AppSettings.selectedAlbumId` — this is
  Initial Album Focus, updated only on successful capture, not on mere selection (DR-7).
- On first run, the 3 most recently used albums are shown (see
  [feature/onboarding/first-run-flow.md](../onboarding/first-run-flow.md)).
- If the album management surface hides the currently-centered album, the loop immediately
  re-resolves its centered/selected album using the same rule as Initial Album Focus (DR-12)
  — this is not a user-initiated loop interaction, but it does change `AlbumLoopState`.
- If no visible albums remain, the loop enters an explicit empty state rather than being
  interacted with as normal — see DR-13 and
  [feature/camera/shooting-flow.md](../camera/shooting-flow.md) AC4.

## Acceptance Criteria
1. Swiping or tapping never triggers a capture — only the centered shutter control does.
2. Album order/position is stable between app sessions except for changes driven by
   `lastUsedAt` recency logic on first run.
3. Hidden albums (`isVisibleInLoop = false`, see [manage-album.md](manage-album.md)) never
   appear in the loop, and a hidden album can never remain the centered/selected album
   (DR-11, DR-12).
4. An empty loop (zero visible albums) is a valid, non-error state (DR-13) — not something
   this spec treats as unreachable.

## Related Specs
- [core/state/state-definitions.md](../../core/state/state-definitions.md) — `AlbumLoopState`
- [fe/widgets/widget-inventory.md](../../fe/widgets/widget-inventory.md) — carousel/reel widget
- [fe/ux/interaction-patterns.md](../../fe/ux/interaction-patterns.md) — swipe physics, fade-by-distance
