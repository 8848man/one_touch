---
title: Domain Rules
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Domain Rules

Authoritative statement of album domain rules (§6, §9, §13, §14). Feature specs reference
this document rather than restating these rules.

## DR-1 — Album Identity
An album in this app **is** a real album that exists in the device's photo gallery, not an
app-internal-only construct. Examples given in the PDF: Camera, 여행, 영수증, 수아사진, 업무.

## DR-2 — System Album Exclusion
System-generated albums are excluded from the loop by default. Named examples: Screenshots,
Download, KakaoTalk, WhatsApp, Messenger.

## DR-3 — Save Target Restriction
Photo capture may only save to: (a) the `Camera` album, or (b) a user-created album. No
other album (including excluded system albums) is a valid save target.

## DR-4 — Duplicate Name Scope
Duplicate-name checking on album creation is scoped to the albums the app currently
recognizes (its own tracked list), not the entire device gallery. Exact user-facing message:
`"동일한 이름의 앨범이 이미 존재합니다."`

## DR-5 — No Delete in MVP
The app provides no album-deletion capability in MVP. This is a deliberate exclusion
(§4), not an oversight — album deletion is `status: roadmap-v2`.

## DR-6 — Loop Cardinality and Structure
No limit on the number of albums shown in the loop. The loop is an infinite carousel.
**Whether this infinite-loop structure is retained is explicitly open** — the PDF states
the decision will be made post-MVP based on user feedback (§9).

## DR-7 — Session Persistence (Initial Album Focus)
The most recently selected album persists across app restarts (`AppSettings.selectedAlbumId`,
§9, §15). This is the sole MVP focus behavior.

**Terminology:** this behavior is referred to as **Initial Album Focus** throughout the SDD.
"Album Focus Policy" is reserved for `roadmap-v1.1`, when Most-Used-Album and User-Pinned-Album
become real, user-selectable alternatives (see [Roadmap Rule Changes](#roadmap-rule-changes-not-active-in-mvp)
below). A single fixed behavior is not a "policy" — do not use "policy" language for the MVP
behavior in feature/UI specs.

**Update trigger (clarification):** `lastUsedAt` — and therefore `selectedAlbumId`'s persisted
value — updates **only on a successful capture** into an album, not on mere carousel
selection/browsing. Selecting an album while swiping the carousel updates in-session state
immediately (visible to the shutter/reel right away) but does not persist as the launch-focus
target until the user actually captures into it. See DR-15 for how this interacts with album
creation specifically.

## DR-8 — No Rename in MVP (Architecture Decision)
Album rename is excluded from MVP, reversing §14's stated inclusion. Reason: no supported
platform API exists for renaming a device gallery album on Android without a risky
folder-level rename requiring explicit user consent (confirmed via technical spike). See
[`sdd/feature/album/manage-album.md`](../../feature/album/manage-album.md) and
[`architecture/feature_guidelines.md`](../../../architecture/feature_guidelines.md).

## DR-9 — Album Creation State Machine (Android/iOS asymmetry)
Android has no "create empty album" API — a folder only exists once the first file is
written into it. The app therefore models a `PendingAlbum` state distinct from a
persisted `Album`:
```
Pending Album → user captures first photo → MediaStore album created → pending state removed
```
Only a persisted `Album` is a valid save target elsewhere in the app (DR-3). iOS supports
explicit pre-creation via `photo_manager`'s `createAlbum()` and does not require this
pending state, but the app models both platforms the same way for consistency. See
[`sdd/feature/album/create-album.md`](../../feature/album/create-album.md).

## DR-10 — System Album Exclusion Mechanism Differs by Platform (implementation note for DR-2)
DR-2's exclusion is enforced differently per platform: iOS uses the native
`PHAssetCollectionType.smartAlbum` flag (exposed by `photo_manager` as `darwinType`);
Android has no equivalent OS-level flag and requires an app-maintained denylist matched
against folder name/path (e.g. `Screenshots`, `WhatsApp Images`, `Download`). This is a
platform capability gap, not a plugin limitation.

## DR-11 — Visibility Precondition on Save Target (clarifies DR-3)
A hidden album (`isVisibleInLoop = false`) is never a valid save target. DR-3's save-target
restriction should be read as requiring both conditions: the album is Camera or user-created
**and** currently visible. No album — including `Camera` — is exempt from Show/Hide; there is
no special-casing by album identity. See
[`sdd/feature/album/manage-album.md`](../../feature/album/manage-album.md).

## DR-12 — Reselection on Hide
If the currently selected album is hidden, the app immediately reselects another visible
album, using the same resolution rule as Initial Album Focus (DR-7: most recently used, among
currently-visible candidates). This is one shared resolution rule applied at two triggers —
app launch, and current-selection-invalidated — not two separate algorithms. See
[`sdd/core/state/state-definitions.md`](../state/state-definitions.md).

## DR-13 — Zero Visible Albums
Hiding the last visible album is allowed, not blocked. The app enters an explicit empty-loop
state: no shutter action is possible (resolves the open question in
[`sdd/feature/camera/shooting-flow.md`](../../feature/camera/shooting-flow.md) AC4), and the
loop area prompts the user to create or unhide an album. A hard block ("you must keep one
album visible") was considered and rejected as inconsistent with the app's no-popups,
minimal-friction interaction philosophy (see
[`sdd/feature/album/save-flow.md`](../../feature/album/save-flow.md)).

## DR-14 — Album Management Shows All Albums
Album Management always lists every album the app recognizes, visible or hidden — managing
visibility is its entire purpose, so hidden albums must remain visible *within that surface*
even though they're absent from the loop. See
[`sdd/feature/album/manage-album.md`](../../feature/album/manage-album.md).

## DR-15 — Album Creation Updates Selection, Not Persistence
Creating an album immediately updates the in-session selected album (visible to the
loop/shutter right away, per [`sdd/feature/album/create-album.md`](../../feature/album/create-album.md)),
but does **not** update persisted `lastUsedAt`/launch-focus (DR-7) until the first successful
capture into that album. Creation alone is not "use" for persistence purposes — only a
capture is. This keeps DR-7's update-trigger definition consistent regardless of whether an
album was just created or has existed for a while.

## Roadmap Rule Changes (not active in MVP)
| Rule change | Target |
|---|---|
| Album delete becomes available | roadmap-v2 |
| Album reorder, color, icon become available | roadmap-v1.1 |
| Album rename becomes available | Not scheduled — would require a resolved Android technical approach (see DR-8) before any target version is assigned |
| Album Focus Policy (Most-Used-Album, User-Pinned-Album alternatives to DR-7's fixed Initial Album Focus) | roadmap-v1.1 |
