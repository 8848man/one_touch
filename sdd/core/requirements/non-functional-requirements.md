---
title: Non-Functional Requirements
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Non-Functional Requirements

## Platform & Distribution
- Android is the primary MVP target; iOS is deferred (§16). See [infra/platform/platform-support.md](../../infra/platform/platform-support.md).
- No server component; no authentication; all data is local to the device (§16).

## Data & Storage
- All photos and album metadata persist locally only; no cloud dependency for MVP operation.
- Storage strategy has two viable implementations pending a technical spike (§5) — see
  [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md).

## Availability of Core Action
- The shutter action is the product's core value proposition ("찍는 순간 어디에 저장될지
  이미 정해져 있는 카메라", §1). **Assumption:** capture-to-save should feel instantaneous
  (no intermediate loading state), since the PDF explicitly excludes preview/toast/result
  popups after capture (§11) — the design intent is a single uninterrupted action, though
  no numeric latency target is given in the source document.

## Permissions Degradation
- The app must remain usable immediately after install without a separate setup screen (§7).
- Denial of camera or photo permission must not crash or dead-end the app; both have a
  defined recovery path via system Settings (§7). See
  [feature/onboarding/first-run-flow.md](../../feature/onboarding/first-run-flow.md).

## Success Metrics (from §17, informational — not testable acceptance criteria)
- Reduced post-capture sorting effort.
- Formation of a pre-capture album-selection habit.
- Reduced photo search time.
- Automatic separation of work/receipt/travel/study material by construction (not by AI).
