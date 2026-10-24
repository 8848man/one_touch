---
title: Dependency Rules
category: architecture
status: mvp
owner: architecture
version: 1.0
source: []
---

# Dependency Rules

## The Rule
```
presentation → domain → data
```
Imports only ever point inward. `di/` is the sole exception — it may import both
`domain/` and `data/` to wire them together.

## Allowed Imports
| From | May import |
|---|---|
| `presentation/` (feature) | its own feature's `domain/`; `common/widgets/`; `core/state/` |
| `domain/` (feature) | its own feature's entities; `core/domain/` (shared kernel) |
| `data/` (feature) | its own feature's `domain/` (to implement interfaces); plugin packages |
| `di/` (feature) | its own feature's `domain/` and `data/` |
| `di/` (root) | any `core/domain/` and any feature's `data/` implementations |
| `core/domain/` | nothing outside itself (pure Dart, no Flutter, no feature imports) |

## Forbidden Imports
- `domain/` importing anything from `package:flutter/*` or any plugin package
  (`camera`, `photo_manager`, `permission_handler`, `shared_preferences`) — these belong
  only in `data/`.
- Any feature's `presentation/` or `domain/` importing another feature's `presentation/`,
  `domain/`, or `data/` directly. Cross-feature sharing goes through `core/domain/` only.
- `presentation/` calling a repository directly — it must go through a UseCase (see
  [riverpod_mvvm.md](riverpod_mvvm.md)).
- Repositories returning plugin-native types (e.g. `photo_manager`'s `AssetPathEntity`)
  across the `data/` → `domain/` boundary — map to domain entities first (see
  [repository_pattern.md](repository_pattern.md)).

## Why the Shared Kernel Doesn't Violate Feature Isolation
`core/domain/` is a stable, feature-agnostic abstraction (entities + repository
interfaces only, no behavior specific to any one feature). Features depending on it is an
inward dependency on a shared foundation, not a feature-to-feature dependency — this is
consistent with the Clean Architecture dependency rule as locked, not an exception to it.

## Related Documents
- [flutter_architecture.md](flutter_architecture.md)
- [folder_structure.md](folder_structure.md)
- [repository_pattern.md](repository_pattern.md)
