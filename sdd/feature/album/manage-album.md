---
title: Album Management
category: feature
status: mvp
owner: feature
version: 1.1
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Album Management

Album Management is the single dedicated surface for album lifecycle: listing, creation, and
carousel visibility. The Camera Screen only consumes album selection — it hosts the carousel
widget but owns none of this behavior (see
[feature/camera/overview.md](../camera/overview.md), `architecture/feature_guidelines.md`).

## Entry Point (§14)
Bottom-left "앨범 관리" action button opens Album Management. This is now also the **sole**
entry point for album creation — the Camera Screen no longer hosts a separate create-album
shortcut. See [create-album.md](create-album.md) for the creation flow this surface triggers.

## Functional Capabilities (MVP)
| Capability | Description |
|---|---|
| Album List | Display every album the app recognizes — visible or hidden (DR-14) |
| Create Album | Triggers [create-album.md](create-album.md)'s flow; sole entry point |
| Show / Hide (Carousel Visibility) | Toggle an album's presence in the carousel without affecting the underlying device album or its photos |

Rename is not listed above — see the exclusion below.

## Rename — Excluded from MVP (Architecture Decision, supersedes §14 이름 수정)

**Status update:** although the PDF's §4/§14 list album rename (앨범명 수정) as an MVP
feature, the technical spike found no supported API for renaming a device gallery album
on Android (the primary MVP platform) without a risky folder-level rename requiring
explicit user consent under scoped storage — see the spike report and
[`architecture/feature_guidelines.md`](../../../architecture/feature_guidelines.md).
Per locked product decision, **rename is excluded from MVP** and must not be implemented
as a physical device-folder rename. This is a deliberate reversal of §14's stated scope,
not an oversight — flagged here so the PDF and this spec don't silently disagree.

## Explicitly Not Provided (§14, 제공하지 않음 + rename per above)
Delete, reorder, color change, icon change, rename. These are roadmap items or excluded
by architecture decision, not omissions:

| Capability | Target status |
|---|---|
| Delete | `roadmap-v2` |
| Reorder | `roadmap-v1.1` |
| Color | `roadmap-v1.1` |
| Icon | `roadmap-v1.1` |
| Rename | Excluded from MVP (architecture decision — see above) |

Do not implement any of the above under this spec — see
[core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-5 (delete) and DR-8 (rename).

## Carousel Visibility — Deterministic Behavior
Show/Hide is a simple boolean toggle (`Album.isVisibleInLoop`), but its downstream effects on
the carousel/save-target state are precisely defined — see
[core/domain/domain-rules.md](../../core/domain/domain-rules.md) DR-11 through DR-14:

| Scenario | Behavior | Rule |
|---|---|---|
| The currently selected album is hidden | The app immediately reselects another visible album (same resolution rule as Initial Album Focus, scoped to remaining visible albums) | DR-12 |
| Hiding would leave zero visible albums | Allowed, not blocked. The app enters an explicit empty-loop state: shutter disabled, loop area prompts create/unhide | DR-13 |
| A hidden album's status inside Album Management | Still listed — Album Management always shows every recognized album, visible or hidden | DR-14 |
| A hidden album as a save target | Never valid — visibility is a precondition on DR-3's save-target restriction | DR-11 |
| The `Camera` album | Subject to the same Show/Hide rules as any other listed album — no special-casing | DR-11 |

## Acceptance Criteria
1. Each row in the management list shows: album name, visibility toggle (no rename control — see above).
2. Toggling visibility off removes the album from the loop immediately without deleting
   underlying photos or the device album itself.
3. Hiding the currently-selected album triggers immediate reselection per DR-12 — the user is
   never left with a hidden album as the active save target.
4. Hiding the last visible album is a valid action; it produces the empty-loop state (DR-13),
   not an error or a blocked interaction.
5. The list always includes hidden albums (DR-14) — visibility here means "show a toggle
   reflecting the current state," not "filter the list by current state."

## Related Specs
- [fe/ui/manage-album-modal.md](../../fe/ui/manage-album-modal.md)
- [fe/ui/new-album-modal.md](../../fe/ui/new-album-modal.md) — creation flow triggered from this surface
- [core/domain/domain-rules.md](../../core/domain/domain-rules.md) — DR-11 through DR-14
- [core/data/data-model.md](../../core/data/data-model.md) — `Album.isVisibleInLoop`, `Album.name`
