# CLAUDE.md — AI Operating Manual

This file governs how AI agents work in this repository. It is **not** a product or
engineering specification — for those, see the references below. This file tells you
how to navigate and behave; it does not restate what those documents already say.

## 1. Project Overview

One-Touch Camera is an album-swipe camera: the destination album is selected *before*
shooting, so capture and organization happen in one action. No login, no server, no
cloud sync in the MVP — local device storage only.

- Full product definition: `one_touch_plan_doc.pdf`
- Full engineering design: [`sdd/README.md`](sdd/README.md) (index of all specs)
- UI/interaction reference only: `camera.html`

## 2. Read Order

1. This file (`CLAUDE.md`)
2. [`sdd/README.md`](sdd/README.md) — locate the spec(s) that own the area you're touching
3. [`architecture/flutter_architecture.md`](architecture/flutter_architecture.md) — the
   frozen implementation architecture, required reading before writing any Dart code
4. The specific `feature/`, `core/`, `fe/`, or `infra/` docs relevant to the task
5. `one_touch_plan_doc.pdf` — only if product intent is still unclear after the SDD
6. `camera.html` — only for UI/interaction detail, never for business rules
7. Source code — last. Code implements the SDD and `architecture/`; it does not define them.

**Working in `v2/`:** the v2 prototype has its own rules. Read [`v2/AGENTS.md`](v2/AGENTS.md)
first (build, versioning and artifact naming rules, e.g. release APKs go to
`v2/releases/one_touch_v2-<version>-release.apk` via `v2/tools/build_release.ps1`), then
[`v2/sdd_v2/README.md`](v2/sdd_v2/README.md). Inside `v2/`, those documents override the
MVP `sdd/` read order above; `roadmap-v2` in this file refers to the MVP roadmap, not the
`v2/` folder.

## 3. Source of Truth

| Document | Owns | Never contains |
|---|---|---|
| `one_touch_plan_doc.pdf` | Business requirements, MVP scope, roadmap | Implementation detail |
| `sdd/` | Engineering design derived from the PDF (architecture, domain rules, data model, feature flows, UI composition) | Facts that contradict the PDF |
| `architecture/` | Frozen Flutter implementation architecture (layers, DI, state, testing) | Business rules or product scope |
| `camera.html` | UI/interaction reference only | Business rules |
| Source code | Implementation of the SDD and `architecture/` | Silent divergence from either |

**Conflict priority:** PDF > `sdd/` > `camera.html` > code assumptions. If code and the
SDD disagree, the SDD is correct until someone deliberately updates it.

## 4. Development Workflow

```
Requirement
    ↓
Locate owning spec in sdd/ (via sdd/README.md)
    ↓
Implementation
    ↓
Self Review (against sdd/process/development-workflow.md checklist)
    ↓
Update the spec if implementation revealed a design change
    ↓
Completion
```

Never start implementing before finding the spec that owns the behavior. If none exists,
that itself is a signal to stop and ask, not to invent one.

## 5. AI Working Principles

- Never invent features not present in `one_touch_plan_doc.pdf` or `sdd/`.
- Never silently expand scope beyond what a `status: mvp` document defines.
- Ask when a requirement is ambiguous or explicitly flagged open (e.g.
  `sdd/feature/camera/camera-settings.md` documents one such open question) — do not guess.
- Treat `roadmap-v1.1`, `roadmap-v2`, and `future` items as out of bounds unless the user
  explicitly asks to pull one forward.
- If implementation forces a design decision, update the owning spec in the same change,
  not as deferred follow-up.
- Never duplicate content across documents — link to the authoritative source instead.

## 6. Documentation Rules

Full authoring rules live in [`sdd/process/spec-authoring-guidelines.md`](sdd/process/spec-authoring-guidelines.md).
Summary only:

- One topic, one authoritative document — cross-reference, never copy.
- Every spec ≤ 300 lines; split before hitting the limit.
- Every spec carries frontmatter with `status: mvp | roadmap-v1.1 | roadmap-v2 | future`.
- Anything not sourced from the PDF is marked `**Assumption:**` inline, never presented as fact.

Do not re-derive or restate these rules elsewhere — link to the guideline doc.

## 7. Coding Principles

**The implementation architecture is frozen.** [`architecture/`](architecture/flutter_architecture.md)
is the permanent standard (Clean Architecture, feature-first, Riverpod, MVVM) — start
there before adding any module. Do not propose an alternative pattern, layer, or state
solution without an explicit architecture review re-approving the change (see
[`architecture/flutter_architecture.md`](architecture/flutter_architecture.md)).
`sdd/core/architecture/architecture-overview.md` remains the conceptual layer summary;
`architecture/` is its concrete Flutter realization.

- Single responsibility per module/widget.
- Feature-first organization: code mirrors `sdd/feature/*` (camera, album, onboarding) —
  see [`architecture/feature_guidelines.md`](architecture/feature_guidelines.md).
- Dependency rule: `presentation → domain → data`, inward only — see
  [`architecture/dependency_rules.md`](architecture/dependency_rules.md).
- Cross-feature entities/repositories live only in the shared kernel (`core/domain/`),
  never duplicated per-feature — see [`architecture/folder_structure.md`](architecture/folder_structure.md).
- Composition over inheritance for UI components (see [`sdd/fe/widgets/widget-inventory.md`](sdd/fe/widgets/widget-inventory.md)).
- Implementation must stay aligned with the SDD and with `architecture/`; a divergence is
  a signal to update the spec, not to let code and docs quietly disagree.

No language-specific style guide exists yet in this repo. If one is added later, it
belongs under `sdd/process/` and should be linked here, not duplicated.

## 8. Development Phases

Authoritative scope tables: [`sdd/core/requirements/functional-requirements.md`](sdd/core/requirements/functional-requirements.md)
(MVP) and [`sdd/core/domain/domain-rules.md`](sdd/core/domain/domain-rules.md) (roadmap
version targets). Do not restate specifics here — only the boundary:

| Phase | What it means for you |
|---|---|
| MVP (`status: mvp`) | Buildable now. Camera capture, album selection/loop, create/manage albums, permission & save-failure handling. |
| `roadmap-v1.1` | Not yet. Album reorder/color/icon. |
| `roadmap-v2` | Not yet. Album delete, in-album photo view, search, favorites. |
| `future` | Not yet, no committed version. OCR, AI classification, cloud sync, sharing — see [`sdd/feature/ai/README.md`](sdd/feature/ai/README.md) and [`sdd/be/future-scope.md`](sdd/be/future-scope.md). |

This section exists only so an AI agent never implements a later phase while believing
it's doing MVP work.

## 9. Task Checklist

Before marking any task complete, verify:

- [ ] Relevant `sdd/` specs were located and reviewed before implementing.
- [ ] Work stays within `status: mvp` scope (unless the user explicitly requested a
      roadmap item).
- [ ] No documentation was duplicated — cross-references used instead.
- [ ] Any `sdd/` spec affected by a design decision was updated in the same change.
- [ ] No touched document exceeds 300 lines.
- [ ] `status` metadata on any touched spec is accurate and unchanged unless the scope
      decision genuinely changed.
- [ ] New assumptions are marked `**Assumption:**`, not stated as fact.

## 10. Decision Rules

When uncertain:

1. Prefer `one_touch_plan_doc.pdf` over any assumption.
2. Prefer the `sdd/` design over an ad hoc implementation choice.
3. Ask the user rather than guessing when a requirement or scope boundary is unclear.
4. Never introduce architecture, dependencies, or patterns not reflected in `sdd/core/architecture/architecture-overview.md`.
