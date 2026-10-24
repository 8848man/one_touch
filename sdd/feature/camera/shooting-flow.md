---
title: Camera — Shooting Flow
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Shooting Flow

## Functional Flow (§10)
```
Album selected (pre-condition, see feature/album/album-loop.md)
        ↓
Center shutter button tapped
        ↓
Photo captured
        ↓
Saved to selected album (see feature/album/save-flow.md)
        ↓
Capture-complete feedback (see feature/album/save-flow.md — success feedback rules)
```

## Acceptance Criteria
1. The center control in the loop area is both the current-album indicator and the shutter
   (§8, 중앙 원형 버튼) — there is exactly one control for this, not two separate elements.
2. Tapping it always captures against whatever album is currently centered in the loop at
   the moment of the tap.
3. Front/back camera flip is available via a dedicated top-left control (§8) and does not
   alter the selected album or interrupt the loop state.
4. No shutter action is possible with zero albums visible in the loop. **Resolved** (was an
   open question in earlier revisions): this is a reachable, valid state — hiding the last
   visible album is allowed, not blocked — and the shutter is disabled with a create/unhide
   prompt shown in the loop area rather than an error. See
   [core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-13 and
   [feature/album/manage-album.md](../album/manage-album.md).

## Related Specs
- [feature/album/save-flow.md](../album/save-flow.md) — what happens after capture
- [infra/camera/camera-integration.md](../../infra/camera/camera-integration.md) — native capture mechanics
- [fe/widgets/widget-inventory.md](../../fe/widgets/widget-inventory.md) — shutter control implementation
