---
title: Development Workflow
category: process
status: mvp
owner: process
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Development Workflow

## Spike-First Sequencing
Per §5, a 1–2 day technical spike must precede MVP feature development, validating the
checklist in [infra/storage/gallery-storage-strategy.md](../infra/storage/gallery-storage-strategy.md).
Feature work should not begin against unresolved storage-strategy assumptions.

## Feature-Aligned Development
Development branches/work items should align to `feature/` directories (camera, album,
onboarding) so that each unit of work has a single corresponding spec set to keep in sync.

## Keeping Docs in Sync with Code
- When implementation reveals a spec's `**Assumption:**` was wrong, update the spec in the
  same change set as the code, not as separate follow-up debt.
- When a roadmap item (`roadmap-v1.1` / `roadmap-v2` / `future`) is pulled forward into
  active development, update its `status` field first, as a deliberate scope decision, then
  begin implementation.

## Review Checklist Before Merging a New/Changed Spec
- [ ] Frontmatter present and `status` accurate.
- [ ] No duplication of content owned elsewhere (link instead).
- [ ] Under 300 lines.
- [ ] Assumptions explicitly marked, not stated as fact.
- [ ] Cross-references resolve to real files.

## Related Specs
- [process/spec-authoring-guidelines.md](spec-authoring-guidelines.md)
- [infra/storage/gallery-storage-strategy.md](../infra/storage/gallery-storage-strategy.md)
