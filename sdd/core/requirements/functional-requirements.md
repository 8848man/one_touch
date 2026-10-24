---
title: Functional Requirements
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Functional Requirements

MVP-included capabilities, per `one_touch_plan_doc.pdf` §4 (포함 기능). Each maps to its
owning feature spec — this document enumerates scope; behavior detail lives in `feature/`.

| # | Requirement | Owning spec |
|---|---|---|
| FR-1 | Camera capture (photo) | [feature/camera/shooting-flow.md](../../feature/camera/shooting-flow.md) |
| FR-2 | Album selection before capture | [feature/album/album-loop.md](../../feature/album/album-loop.md) |
| FR-3 | Instant save to selected album on capture | [feature/album/save-flow.md](../../feature/album/save-flow.md) |
| FR-4 | Album loop (carousel navigation) | [feature/album/album-loop.md](../../feature/album/album-loop.md) |
| FR-5 | Create new album | [feature/album/create-album.md](../../feature/album/create-album.md) |
| FR-6 | Manage albums (show/hide in loop) | [feature/album/manage-album.md](../../feature/album/manage-album.md) |
| FR-7 | Permission-denied handling (camera, photos) | [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md) |
| FR-8 | Save-failure handling | [feature/album/save-flow.md](../../feature/album/save-flow.md) |
| FR-9 | First-run flow (permissions → recent albums → camera) | [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md) |
| FR-10 | Settings (global application preferences, MVP content intentionally minimal) | [feature/settings/overview.md](../../feature/settings/overview.md) |

**Note:** Initial Album Focus (resuming on the last-used album, DR-7) is not a separate FR —
it's an extension of the already-tracked FR-9/returning-user scope, not a new capability
category.

## Explicitly Excluded from MVP

Per §4 (제외 기능): login, signup, server, cloud sync, OCR, AI auto-classification, sharing,
collaboration, album deletion. See [core/domain/domain-rules.md](../domain/domain-rules.md)
for the album-deletion exclusion specifically, and [feature/ai/README.md](../../feature/ai/README.md)
/ [be/future-scope.md](../../be/future-scope.md) for roadmap treatment of OCR/AI/cloud.

**Architecture-decision exclusion (post-spike):** album rename, though listed in §4/§14 of
the PDF, is excluded from MVP due to a confirmed Android platform limitation — see
[core/domain/domain-rules.md](../domain/domain-rules.md) DR-8.

**Partially resolved:** of the settings-button example contents listed in §8 ("포함 기능
예시": flash / aspect ratio / timer), flash is now confirmed as a Camera Screen runtime
control (not Settings content, not excluded). Aspect ratio and timer remain an open scope
question — see [feature/camera/camera-settings.md](../../feature/camera/camera-settings.md).
