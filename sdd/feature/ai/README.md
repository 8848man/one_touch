---
title: AI Feature — Future Stub
category: feature
status: future
owner: feature
version: 0.1
source:
  - one_touch_plan_doc.pdf
---

# AI Feature (Future Stub)

## Status: Future — Not MVP, Not V1.1, Not V2

Per §18 (향후 로드맵 → Future), the following are explicitly future-only, with no nearer
roadmap slot assigned: OCR, AI 자동 분류 (AI auto-classification), AI 문서 정리 (AI document
organization).

## Why This Folder Exists Now
To prevent scope ambiguity: this stub exists so that "AI" is visibly future-scoped in the
SDD structure rather than silently absent (which could be misread as an oversight) or
implicitly implied as near-term (which the PDF does not support).

## No Specifications Are Generated Here
Per the source document, MVP explicitly excludes AI auto-classification (§4, 제외 기능).
No functional, data, or architectural specs should be authored under this path until the
capability is promoted from "Future" to a scheduled roadmap version in a revised product
specification.

## Anticipated Cross-Cutting Impact (Assumption, non-binding)
If/when promoted, AI classification would likely require:
- Backend or on-device inference capability — see [be/future-scope.md](../../be/future-scope.md).
- Revisiting [core/domain/domain-rules.md](../../core/domain/domain-rules.md) (e.g. auto-assignment
  interacting with manual album selection).

These are noted only to avoid designing the current MVP in a way that would block this
future work — they are not commitments.
