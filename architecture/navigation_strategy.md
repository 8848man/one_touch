---
title: Navigation Strategy
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/fe/navigation/navigation-map.md
---

# Navigation Strategy

## MVP Reality
Per [`sdd/fe/navigation/navigation-map.md`](../sdd/fe/navigation/navigation-map.md), the
MVP has one screen and three dismissable modals — no multi-route stack, no deep linking,
no named-route table needed. Settings is the third modal (added when it moved from deferred
to a confirmed MVP destination) and does not change this approach — it's presented the same
way as the other two, not as a routed screen.

## Approach
- The main camera screen is the app's single root route.
- New Album, Album Management, and Settings are all presented as modal overlays (e.g.
  `showModalBottomSheet`/`showDialog`-equivalent), controlled by `ModalState` in
  `core/state/state-definitions.md`, not by pushing new routes.
- Do not introduce a routing package (e.g. `go_router`) for MVP — there is nothing for it
  to route between yet. Revisit only if V2 (album search, in-album photo view) or later
  phases introduce genuine multi-screen navigation.

## Rule
Navigation state (which modal, if any, is open) lives in the relevant ViewModel's state
(`ModalState`), not in a separate navigation/router layer. This avoids introducing routing
infrastructure disproportionate to the current screen count.

## Related Documents
- [riverpod_mvvm.md](riverpod_mvvm.md)
- [state_management.md](state_management.md)
