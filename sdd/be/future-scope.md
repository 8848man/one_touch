---
title: Backend — Future Scope
category: be
status: future
owner: be
version: 0.1
source:
  - one_touch_plan_doc.pdf
---

# Backend — Future Scope

## Why No Backend Exists in MVP
§16 states explicitly: 서버 없음 (no server), 로그인 없음 (no login), 저장은 로컬 저장
(storage is local). §4 confirms server, cloud sync, login, and signup are explicitly
excluded from MVP scope. This is a deliberate MVP boundary, not a gap to fill in silently.

## Expected Future Responsibilities
Per §18 (Future roadmap section), the following would require backend support if pursued:
- **클라우드 백업** (cloud backup)
- **기기 간 동기화** (cross-device sync)
- **공유 앨범** (shared albums)
- **OCR** and **AI 자동 분류 / AI 문서 정리** (AI classification/organization) — likely
  requiring server-side or managed inference, depending on chosen approach; see
  [feature/ai/README.md](../feature/ai/README.md).

None of these have an assigned target version (V1.1/V2) in the source document — they sit
under "Future" only, meaning no committed timeline exists yet.

## Possible Future Architecture (Assumption — non-binding sketch)
If/when backend work is prioritized, likely needs include: user identity (to support
cross-device sync and shared albums), a sync protocol reconciling local-first data with
a remote store, and either server-side or on-device inference for AI/OCR features. This is
speculative scaffolding only, intended to flag design decisions in `core/data` and
`core/domain` (e.g., keeping IDs sync-friendly) that could ease this transition — it is
**not** a commitment to any specific technology or timeline.

## No Implementation Specs
Per instruction, no implementation-level backend specifications are generated at this
stage. This document exists solely to record rationale and anticipated future scope.
