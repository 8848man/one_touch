---
title: Camera — Settings (Partially Resolved)
category: feature
status: mvp
owner: feature
version: 1.1
source:
  - one_touch_plan_doc.pdf
---

# Camera Settings

## Status: Flash Resolved, Ratio/Timer Still Unconfirmed

§8 describes a top-right settings button on the main screen with "포함 기능 예시"
(example included features): 플래시 (flash), 비율 (aspect ratio), 타이머 (timer). This was
listed as an *example* of what that button might contain, not confirmed in the §4 MVP
feature list.

**Resolved (product decision):** Flash is a Camera Screen runtime control, not Settings
content — it ships alongside capture, camera flip, and the carousel as part of Camera
Screen's runtime-only responsibility set. This is a deliberate reversal of §8's literal
grouping (which implied flash lived behind the settings icon): §8 only offered flash as an
*example*, and runtime camera controls belonging with the viewfinder — rather than behind a
separate global-preferences surface — is both more consistent with common camera-app
convention and with the Settings/Camera Screen boundary now locked in
[fe/ui/main-camera-screen.md](../../fe/ui/main-camera-screen.md) and
[feature/settings/overview.md](../../feature/settings/overview.md) (Settings owns only
global application preferences, never camera runtime controls).

**Still unconfirmed:** aspect ratio and timer remain unconfirmed MVP scope. Do not implement
either until confirmed; do not assume they follow flash's resolution — they were not part of
the frozen product decision that resolved flash's placement.

## Action Required
Product owner should confirm whether ratio/timer are MVP-committed (and if so, on Camera
Screen alongside flash, per the same runtime-control reasoning) or should be reclassified as
`roadmap-v1.1`. Until then this spec exists to prevent silent scope assumptions during
implementation.

## Related Specs
- [feature/camera/overview.md](overview.md)
- [feature/settings/overview.md](../../feature/settings/overview.md) — the boundary flash's resolution depends on
- [fe/ui/main-camera-screen.md](../../fe/ui/main-camera-screen.md)
