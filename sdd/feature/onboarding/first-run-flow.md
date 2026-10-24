---
title: Onboarding — First-Run Flow
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# First-Run Flow

## Functional Flow (§7)
```
App launch
        ↓
Camera permission request
        ↓
Photo access permission request
        ↓
Album list fetch
        ↓
Auto-display 3 most recently used albums
        ↓
Enter main camera screen
```

## Purpose
User must be able to shoot immediately after install, with no separate setup screen (§7).

## Permission-Denied Sub-Flows

### Camera permission denied
```
"권한이 필요합니다" → Go to Settings → Grant → Re-enter app
```

### Photo access permission denied
```
"앨범 기능 사용을 위해 사진 접근 권한이 필요합니다." → Go to Settings → Grant → Re-enter app
```

## Returning Users
On subsequent launches, skip the onboarding sequence entirely; Initial Album Focus is applied
(`AppSettings.hasCompletedOnboarding`, `AppSettings.selectedAlbumId`) — see
[core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-7,
[core/state/state-definitions.md](../../core/state/state-definitions.md) `AppLaunchState`,
and [feature/album/album-loop.md](../album/album-loop.md).

## Acceptance Criteria
1. First run always requests camera permission before photo permission (order matters, per §7).
2. Neither permission denial is a dead end — both have an OS-level Settings recovery path
   (device Settings app, via deep link — not this app's own in-app Settings surface, see
   [feature/settings/overview.md](../../feature/settings/overview.md)).
3. No dedicated onboarding/tutorial screen exists; the flow above happens against system
   permission dialogs only, landing directly on the camera screen.

## Related Specs
- [infra/permissions/permission-handling.md](../../infra/permissions/permission-handling.md)
- [core/state/state-definitions.md](../../core/state/state-definitions.md)
