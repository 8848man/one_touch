---
title: Architecture Overview
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Architecture Overview

**Note on framework:** the PDF does not specify an implementation framework. Flutter is
the mandated implementation target for this SDD per the project brief commissioning this
document, not a fact derived from `one_touch_plan_doc.pdf`.

**Concrete implementation architecture:** Clean Architecture (Riverpod, MVVM, feature-first)
is now locked and detailed in [`architecture/flutter_architecture.md`](../../../architecture/flutter_architecture.md)
and its companion documents. This document remains the conceptual layer summary; do not
duplicate layer/DI/state-management detail here — see `architecture/` for that.

## Layers

1. **Feature layer** (`feature/` docs, implemented per-capability in app code) — camera,
   album, onboarding. Owns business flow and acceptance criteria.
2. **Core domain layer** (`core/domain`, `core/data`, `core/state`) — album/photo/settings
   model, domain rules (system-album exclusion, save-target restriction, naming policy),
   and state shape shared across features.
3. **Frontend layer** (`fe/`) — screen composition, widgets, navigation, interaction
   patterns implementing the feature layer's behavior.
4. **Infrastructure layer** (`infra/`) — native platform integration: camera capture,
   gallery/MediaStore access, permission APIs. This is the highest-risk area technically,
   per the PDF's own pre-MVP spike requirement (§5).

## No Backend / No Client-Server Split

MVP is a fully local, single-device application (§16: 서버 없음, 로그인 없음, 로컬 저장).
There is no client-server boundary to design in this document set. See
[be/future-scope.md](../../be/future-scope.md) for anticipated future architecture once
cloud sync / shared albums / AI processing are prioritized.

## Data Flow (MVP)

```
Camera capture (infra/camera)
        │
        ▼
Selected Album (core/state — AlbumLoopState)
        │
        ▼
Local Gallery Save (infra/storage)
        │
        ▼
Feedback (fe/ux — flash + saved-tag, no preview/toast per feature/album/save-flow.md)
```

## Cross-References
- [core/domain/domain-rules.md](../domain/domain-rules.md)
- [core/data/data-model.md](../data/data-model.md)
- [core/state/state-definitions.md](../state/state-definitions.md)
- [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md)
