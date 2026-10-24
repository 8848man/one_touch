---
title: UI — Album Management Modal
category: fe
status: mvp
owner: fe
version: 1.1
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Album Management Modal

Implements [feature/album/manage-album.md](../../feature/album/manage-album.md). Composition
only. Filename kept as `manage-album-modal.md` to avoid cross-reference churn across the SDD;
the surface itself is titled/labeled "Album Management" per the current naming standard.

## Composition (camera.html, consistent with §14; revised for single-entry-point creation)
- Title: "앨범 관리" (Album Management)
- Description text explaining show/hide capability. **No rename-related copy or controls** —
  rename is excluded from MVP (DR-8); earlier revisions of this document incorrectly retained
  an edit/save toggle and inline-rename affordance, which is corrected here.
- "Create" action (new) — opens [new-album-modal.md](new-album-modal.md) on top of this
  modal. This is now the sole entry point for album creation; see
  [feature/album/create-album.md](../../feature/album/create-album.md).
- Scrollable list, one row per album — **all recognized albums, visible or hidden** (DR-14):
  - Album name (static text — no inline edit, see above)
  - Visibility toggle switch (on/off, reflects `Album.isVisibleInLoop`)
- Single "완료" (done) button to close.

## Carousel Visibility Behavior Reflected Here
- Toggling a row's visibility off while it is the currently-selected album triggers immediate
  reselection elsewhere in the app (DR-12) — this modal does not need its own confirmation
  step for that transition; it's a background state change, not a destructive action.
- Toggling off the last visible album is allowed; the Main Camera Screen enters the empty-loop
  state (DR-13) the next time it's visible. This modal does not block the toggle or show a
  warning — consistent with the app's minimal-friction interaction philosophy.

## Explicitly Absent Controls
No delete button, no reorder handle, no color/icon picker, no rename control — consistent
with [feature/album/manage-album.md](../../feature/album/manage-album.md)'s roadmap table and
DR-8. Do not add these controls under `status: mvp`.

## Related Specs
- [feature/album/manage-album.md](../../feature/album/manage-album.md)
- [new-album-modal.md](new-album-modal.md) — creation flow triggered from this surface
- [core/domain/domain-rules.md](../../core/domain/domain-rules.md) — DR-8, DR-11 through DR-14
- [fe/widgets/widget-inventory.md](../widgets/widget-inventory.md) — toggle switch
