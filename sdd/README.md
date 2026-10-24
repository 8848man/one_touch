---
title: One-Touch Camera — SDD Index
category: process
status: mvp
owner: process
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# One-Touch Camera — Software Design Document

Album-swipe camera: the album destination is chosen before shooting, so capture and
organization happen in a single action. See [feature/camera/overview.md](feature/camera/overview.md)
and [feature/album/overview.md](feature/album/overview.md) for the core product concept.

## Directory Responsibilities

| Directory | Answers | Must never contain |
|---|---|---|
| `feature/` | What the system does (business capability, flow, acceptance criteria) | Widget names, layout, implementation details |
| `core/` | Project-wide engineering foundation (architecture, requirements, domain rules, state, data) | Feature-specific UI or flow detail |
| `fe/` | How the app is implemented on screen (widgets, navigation, UX, interaction) | Business rules already defined in `feature/` |
| `be/` | Why there is no backend yet, and what future backend responsibilities look like | Any implementation spec (MVP has no backend) |
| `infra/` | Platform/native integration (camera, permissions, storage, platform limits) | Business or UI decisions |
| `deployment/` | Release/distribution process for the current MVP | Backend deployment (none exists) |
| `process/` | How this SDD itself is authored and maintained | Product or technical content |
| `screen_ref/` | Visual reference only (HTML prototype, mockups, wireframes, screenshots) | Business rules or implementation detail |

## Single Source of Truth Rules

1. Every fact lives in exactly one document. Other documents link to it via relative path, never copy it.
2. `one_touch_plan_doc.pdf` is authoritative for all business behavior. `camera.html` is authoritative only for visual/interaction reference and is superseded by the PDF on any conflict.
3. Every spec carries `status: mvp | roadmap-v1.1 | roadmap-v2 | future` so scope is legible without surrounding context.
4. Anything not explicitly stated in the PDF is marked `**Assumption:**` inline rather than presented as fact.

## Full Specification Map

See each section's own README/overview for the authoritative index of that directory's documents:
- [feature/](feature/) — camera, album, onboarding, settings, ai (future stub)
- [core/](core/) — requirements, architecture, domain, state, data
- [fe/](fe/) — ui, ux, widgets, navigation
- [be/](be/future-scope.md) — future scope only
- [infra/](infra/) — camera, permissions, storage, platform
- [deployment/](deployment/deployment-overview.md)
- [process/](process/)
- [screen_ref/](screen_ref/)
- [implementation-spec-v2.md](implementation-spec-v2.md) — v2 구현 명세 초안 (Figma 주석 기반, `status: roadmap-v2`)
