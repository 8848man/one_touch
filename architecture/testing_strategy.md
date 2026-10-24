---
title: Testing Strategy
category: architecture
status: mvp
owner: architecture
version: 1.0
source: []
---

# Testing Strategy

## Scope, Kept Proportionate to MVP
This is a 3-feature MVP with no backend. The testing strategy below is intentionally
narrow — do not expand it into a full pyramid the project doesn't yet need.

## What to Test
| Layer | Test type | Priority |
|---|---|---|
| `domain/` (UseCases, entities) | Unit tests, pure Dart, no mocks needed for entities | High — cheap and high-value since domain has no Flutter/plugin dependency |
| `data/` (repository implementations) | Unit tests against a faked plugin interface | Medium — focus on the mapping logic (plugin type → domain entity), not the plugin itself |
| `presentation/` (ViewModels) | Unit tests with fake UseCases injected via `di/` | Medium — verify state transitions (e.g. `CaptureState` idle→capturing→success/failure) |
| Widgets/screens | Widget tests for the 3 MVP surfaces only (main screen, new-album modal, manage-album modal) | Low-to-medium — smoke-level, not exhaustive |

## What Not to Test (for MVP)
- Do not write end-to-end/integration tests against real device cameras or real gallery
  writes as part of the standard suite — the technical spike already identified this as
  needing manual device-matrix verification, not CI automation, given plugin/OEM variance.
- Do not test `photo_manager`/`camera`/`permission_handler` internals — trust the plugin,
  test only your mapping/wrapper code around it.

## Where Test Doubles Are Substituted
Per [dependency_injection.md](dependency_injection.md), fakes/mocks replace concrete
`data/` implementations at the `di/` boundary — `domain/`'s pure-Dart nature means UseCase
tests need no Flutter test harness at all.

## Related Documents
- [dependency_injection.md](dependency_injection.md)
- [repository_pattern.md](repository_pattern.md)
