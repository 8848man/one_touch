---
title: Album Feature — Overview
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Album Feature — Overview

## Purpose
Move sorting to before capture: the user always has a clear, currently-selected album,
browsable via a horizontal loop, that the shutter saves into (§1, §3).

## Business Capability
- Browse and select destination albums via swipe/tap loop (Camera Screen hosts this; the
  Album feature owns it — see `architecture/feature_guidelines.md`).
- Create new albums (which are real device gallery albums) — single entry point via Album
  Management.
- Manage existing albums: show/hide in loop. Rename is explicitly excluded (DR-8), not a
  capability of this feature.

## Specifications in this Feature
| Spec | Responsibility |
|---|---|
| [album-definition.md](album-definition.md) | What counts as an album usable by this app |
| [album-loop.md](album-loop.md) | Carousel selection/navigation behavior |
| [create-album.md](create-album.md) | New album creation flow, sole entry point, full lifecycle |
| [manage-album.md](manage-album.md) | Album Management: list, create-trigger, visibility toggle; explicitly not delete/reorder/rename |
| [save-flow.md](save-flow.md) | Post-capture save behavior and failure handling |

## Explicitly Out of Scope (MVP)
Album deletion, reordering, color, icon — see [core/domain/domain-rules.md](../../core/domain/domain-rules.md)
roadmap table for target versions.

## Related Specs
- Domain authority: [core/domain/domain-rules.md](../../core/domain/domain-rules.md)
- Data shape: [core/data/data-model.md](../../core/data/data-model.md)
- Screen composition: [fe/ui/main-camera-screen.md](../../fe/ui/main-camera-screen.md),
  [fe/ui/new-album-modal.md](../../fe/ui/new-album-modal.md), [fe/ui/manage-album-modal.md](../../fe/ui/manage-album-modal.md)
- Storage mechanics: [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md)
