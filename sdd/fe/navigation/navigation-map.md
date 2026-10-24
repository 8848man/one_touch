---
title: Navigation Map
category: fe
status: mvp
owner: fe
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Navigation Map

## MVP Navigation Graph
The MVP is effectively a single main screen with three dismissable modal overlays — there is
no multi-screen route stack, and Settings does not introduce one (see
`architecture/navigation_strategy.md`).

```
App Launch
    │
    ▼
[Onboarding: permission flow] (first run only, see feature/onboarding/first-run-flow.md)
    │
    ▼
Main Camera Screen ⇄ Album Management Modal ⇄ New Album Modal
       │                (sole entry point for both
       │                 listing/visibility and creation)
       ⇄ Settings Modal
```

- Album Management is the single entry point for album creation — tapping "Create" inside it
  opens New Album Modal on top; there is no longer a standalone create-album trigger on the
  Main Camera Screen. See [feature/album/manage-album.md](../../feature/album/manage-album.md).
- All three modals return to Main Camera Screen on dismiss (cancel/done) or on completing
  their action (create/manage/preference change).
- No modal navigates to any further screen beyond this graph.
- Settings **is** a real MVP destination (resolved — previously unconfirmed): a modal, not a
  routed screen, holding only global preferences. See
  [feature/settings/overview.md](../../feature/settings/overview.md).

## No Deep Linking / No Multi-Route State
Given the absence of login, sharing, or backend (§4, §16), there is no requirement for
deep links, route history, or multi-tab navigation in MVP.

## Related Specs
- [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md)
- [feature/settings/overview.md](../../feature/settings/overview.md)
- [fe/ui/main-camera-screen.md](../ui/main-camera-screen.md)
- [architecture/navigation_strategy.md](../../../architecture/navigation_strategy.md)
