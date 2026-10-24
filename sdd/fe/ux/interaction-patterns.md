---
title: UX — Interaction Patterns
category: fe
status: mvp
owner: fe
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Interaction Patterns

Motion/animation detail supplementing [feature/album/save-flow.md](../../feature/album/save-flow.md)
and [feature/album/album-loop.md](../../feature/album/album-loop.md). Business rule (what
feedback occurs) lives in `feature/`; this document covers how it moves.

## Capture Feedback
- **Business rule (authoritative):** brightness flash OR short flash effect only, no
  preview/toast/popup (§11, see [feature/album/save-flow.md](../../feature/album/save-flow.md)).
- **Assumption (prototype-sourced motion detail, not PDF-mandated):** camera.html implements
  this as a full-screen white flash (~0.45s ease-out, peak opacity ~90% at 12% of duration)
  layered with a short "saved to {album}" pulse label (~0.7s) that fades in/out. Treat exact
  timings as a starting point, not a locked spec.

## Carousel Swipe / Drag
- Swipe or drag beyond a small threshold moves the selection one step (camera.html: ~40px
  threshold; **Assumption**, not PDF-specified).
- Transition uses an eased slide (camera.html: cubic-bezier ease, ~0.30–0.34s).
- Distance-based visual de-emphasis: the centered album is largest/full-opacity; each step
  away from center reduces size and opacity progressively until near-invisible at extreme
  distance (camera.html convention).

## Visibility Toggle (Album Management Modal)
- Visibility toggle is a binary on/off switch with a sliding thumb.
- Toggling off the currently-selected album triggers a silent reselection elsewhere in the
  app (DR-12) — no animation or confirmation is specified for this transition; it is a
  background state change, not a user-facing event within this modal.
- **Removed:** rename edit-in-place motion previously described here ("수정"/"저장" label
  swap). Rename is excluded from MVP (DR-8); this interaction no longer exists anywhere in
  the app and should not be implemented.

## Related Specs
- [feature/album/save-flow.md](../../feature/album/save-flow.md)
- [feature/album/album-loop.md](../../feature/album/album-loop.md)
- [fe/widgets/widget-inventory.md](../widgets/widget-inventory.md)
