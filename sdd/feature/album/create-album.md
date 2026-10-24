---
title: Album — Create New Album
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Create New Album

## Functional Flow (§13)
```
Tap "Create" inside Album Management (see feature/album/manage-album.md)
        ↓
Enter album name
        ↓
Tap "생성" (create)
        ↓
Real album created in device gallery
        ↓
Automatically added to the loop (isVisibleInLoop = true)
        ↓
Automatically selected as current album
```

**Entry point (revised):** Album creation has a single authoritative entry point — the
"Create" action inside Album Management. The Camera Screen does not host a standalone
create-album shortcut; this deliberately deviates from §13's literal bottom-right-button
placement (a UI-layout detail, not a business rule — see `CLAUDE.md`'s source-of-truth
table) in favor of one authoritative path per [manage-album.md](manage-album.md)'s ownership
model. Creation is an infrequent action (once per album, reused many times via the loop),
so consolidating it costs negligible speed while removing a duplicate-path maintenance
liability.

## Business Rules
- Duplicate-name check is scoped to albums the app currently recognizes, not the entire
  device gallery (DR-4).
- On duplicate: show inline error, do not create — exact message:
  `"동일한 이름의 앨범이 이미 존재합니다."`

## Platform Note: Pending Album State (DR-9)
On Android, the device gallery album does not physically exist until the first photo is
written into it. Creation therefore follows a state machine, not an immediate persisted
result:
```
Pending Album → user captures first photo → MediaStore album created → pending state removed
```
The loop displays the pending album immediately (satisfying the user-facing flow below),
but it is not yet a valid save target at the OS level until the first capture completes —
see [core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-9. iOS creates the
album immediately via a native API and does not need this intermediate state, but the app
models both platforms identically for UI consistency.

## Complete Post-Creation Lifecycle (DR-15)
1. Album is added to the loop, visible (`isVisibleInLoop = true` by default — required for it
   to be selectable at all, per DR-11).
2. Album immediately becomes the selected album (in-session state, visible to the loop/shutter
   right away).
3. The album is immediately capturable — via the existing Pending Album mechanism (DR-9), the
   first capture is what actually materializes the MediaStore folder; there is no separate
   "activation" step.
4. Creation does **not** by itself update persisted `lastUsedAt`/launch-focus (DR-7) — only a
   successful capture into the new album does (DR-15). A user who creates an album and closes
   the app without capturing will not resume on that album next launch; the in-session
   selection and the persisted launch-focus are deliberately distinct.

## Acceptance Criteria
1. Successful creation always results in the new album being both loop-visible and selected.
2. Empty name input must not be submittable (**Assumption:** inferred from standard form
   validation; not explicitly stated in PDF, but implied by requiring name entry before creation is enabled).
3. Creation failure due to platform/storage error follows the same failure pattern as
   [feature/album/save-flow.md](save-flow.md)'s failure modal (**Assumption:** PDF does not
   explicitly cover album-creation failure, only photo-save failure — treat as same UX
   pattern for consistency pending product confirmation).
4. A newly created album is immediately capturable (step 3 above) but does not become the
   persisted launch-focus target until actually captured into (step 4 above; DR-15).

## Related Specs
- [manage-album.md](manage-album.md) — sole entry point / owning surface
- [core/domain/domain-rules.md](../../core/domain/domain-rules.md) — DR-4, DR-9, DR-15
- [fe/ui/new-album-modal.md](../../fe/ui/new-album-modal.md) — modal composition
- [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md) — how album creation is persisted to the device gallery
