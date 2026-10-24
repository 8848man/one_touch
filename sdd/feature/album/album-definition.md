---
title: Album — Definition (Feature View)
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Album — Definition (Feature View)

This document describes the user-facing implication of album identity. The authoritative
rule statements live in [core/domain/domain-rules.md](../../core/domain/domain-rules.md)
(DR-1 through DR-4) — this spec references them rather than restating them.

## User-Facing Behavior
- Every album a user sees in this app corresponds to a real album in their phone's photo
  gallery (DR-1). There is no app-only "virtual album" concept.
- Albums the user didn't create and wouldn't recognize as their own (Screenshots,
  KakaoTalk, etc.) do not clutter the loop by default (DR-2).
- The loop and save actions are restricted to `Camera` + user-created albums only (DR-3).

## Acceptance Criteria
1. On first load, the app's album list must exclude known system albums by default (DR-2).
2. A user must not be able to select an excluded system album as a save target through any
   in-app control (DR-3) — this includes the loop, the settings modal, and creation flow.

## Related Specs
- [core/domain/domain-rules.md](../../core/domain/domain-rules.md)
- [feature/album/album-loop.md](album-loop.md)
- [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md)
