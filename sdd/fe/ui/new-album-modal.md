---
title: UI — New Album Modal
category: fe
status: mvp
owner: fe
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# New Album Modal

Implements [feature/album/create-album.md](../../feature/album/create-album.md). Composition only.

## Entry Point (revised)
Opened from within [manage-album-modal.md](manage-album-modal.md)'s "Create" action — no
longer from a standalone Main Camera Screen button. See
[feature/album/create-album.md](../../feature/album/create-album.md) for the rationale
(single authoritative entry point for album creation).

## Composition (camera.html, consistent with §13)
- Title: "새 앨범 만들기"
- Description text explaining that a real gallery album will be created and added to the loop.
- Single text input for album name (**Assumption:** 20-character max length is from the
  HTML prototype only; not stated in the PDF — confirm before treating as a hard limit).
- Inline error message (hidden by default), shown on duplicate name: "동일한 이름의 앨범이 이미 존재합니다."
- Two actions: 취소 (cancel, dismisses without effect), 생성 (create, per business flow).

## Behavior Notes
- Modal is dismissible via cancel or by tapping outside its bounds (camera.html convention;
  **Assumption:** not specified in PDF).
- On successful creation, modal closes and the loop auto-selects the new album (per
  [feature/album/create-album.md](../../feature/album/create-album.md)).

## Related Specs
- [feature/album/create-album.md](../../feature/album/create-album.md) — business rules
- [core/domain/domain-rules.md](../../core/domain/domain-rules.md) — DR-4 duplicate scope
