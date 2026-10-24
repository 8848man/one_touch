---
title: Specification Authoring Guidelines
category: process
status: mvp
owner: process
version: 1.0
source: []
---

# Specification Authoring Guidelines

## Frontmatter (required on every spec)
```yaml
---
title: <Human-readable title>
category: feature | core | fe | be | infra | deployment | process | screen_ref
status: mvp | roadmap-v1.1 | roadmap-v2 | future
owner: <matches top-level directory>
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html   # only if the HTML prototype is genuinely relevant
---
```

## Single Responsibility
Each document covers exactly one topic. If a spec starts covering two concerns (e.g., a
business flow and its screen layout), split it along the `feature/` vs `fe/` boundary.

## 300-Line Limit
No specification may exceed 300 lines. Split before that limit is reached, not after.

## Cross-Reference, Never Duplicate
If information already exists in another document, link to it with a relative path.
Never restate a rule, field list, or flow that already has an authoritative home.

## Boundary Rules
- `feature/` — what and why (business capability, flow, acceptance criteria). No widget
  names, no layout detail.
- `fe/` — how (composition, widgets, navigation, motion). Never redefines a business rule
  already in `feature/`; references it instead.
- `screen_ref/` — visual reference only (HTML/mockups/wireframes/screenshots). Never a
  source of business rules — the PDF always wins on conflict.
- `core/` — project-wide concepts (architecture, requirements, domain, state, data) used
  by multiple features, not feature-specific detail.

## Marking Assumptions
Anything not explicitly stated in `one_touch_plan_doc.pdf` must be prefixed
`**Assumption:**` inline, with a note on why it was inferred. Never present an inferred
detail as a source-backed fact.

## Status Field Discipline
`status` must reflect the *source document's* scope classification (MVP §4, or roadmap
§18 V1.1/V2/Future), not the author's guess at priority. Promote a spec's status only when
the underlying product decision has actually changed.
