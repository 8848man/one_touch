---
title: Camera Feature — Overview
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
  - camera.html
---

# Camera Feature — Overview

## Purpose
"찍는 순간 어디에 저장될지 이미 정해져 있는 카메라" (§1) — the user picks a destination
album before shooting; pressing the shutter both captures and files the photo in one action.

## Business Capability
- Live camera preview with front/back flip (§8).
- Flash (confirmed runtime control — resolved, see [camera-settings.md](camera-settings.md)).
- Single shutter action that captures a photo and immediately commits it to whichever
  album is currently selected in the loop.
- Hosts the album carousel (selection only — ownership stays with the `album` feature, see
  `architecture/feature_guidelines.md`) and, per its own action button, the entry point into
  Album Management.

## In Scope (MVP)
- Capture flow: [shooting-flow.md](shooting-flow.md)
- Flash: [camera-settings.md](camera-settings.md) — resolved as a Camera Screen runtime control
- Camera settings button presence: [camera-settings.md](camera-settings.md) (ratio/timer contents still unconfirmed)

## Out of Scope (MVP)
- OCR / AI auto-classification of captured photos — `status: future`, see
  [feature/ai/README.md](../ai/README.md).

## Related Specs
- Save destination logic: [feature/album/save-flow.md](../album/save-flow.md)
- Album selection mechanism: [feature/album/album-loop.md](../album/album-loop.md)
- Screen composition: [fe/ui/main-camera-screen.md](../../fe/ui/main-camera-screen.md)
- Native capture integration: [infra/camera/camera-integration.md](../../infra/camera/camera-integration.md)
- Visual reference: [screen_ref/screen-specifications.md](../../screen_ref/screen-specifications.md)
