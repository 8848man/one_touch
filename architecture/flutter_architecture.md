---
title: Flutter Architecture — Overview
category: architecture
status: mvp
owner: architecture
version: 1.0
source:
  - sdd/core/architecture/architecture-overview.md
---

# Flutter Architecture — Overview

This is the permanent implementation architecture for this repository (frozen per
2026 architecture review). It implements the conceptual layers already described in
[`sdd/core/architecture/architecture-overview.md`](../sdd/core/architecture/architecture-overview.md)
using a concrete Flutter stack. Do not restate business/product content here — see
`one_touch_plan_doc.pdf` and `sdd/` for that.

## Locked Technology Stack
| Concern | Choice |
|---|---|
| State management / DI | Riverpod |
| Presentation pattern | MVVM (one ViewModel per screen) |
| Code organization | Feature-first |
| Layering | Clean Architecture (presentation → domain → data) |
| Camera | `camera` (official Flutter plugin) |
| Album/gallery | `photo_manager` |
| Permissions | `permission_handler` |
| App settings | `shared_preferences` |

## Dependency Rule
```
presentation → domain → data
```
Dependencies point inward only. `domain/` has no Flutter import. `data/` implements
`domain/`'s repository interfaces. `di/` is the only layer allowed to know about both
`domain/` and `data/` simultaneously — see [dependency_rules.md](dependency_rules.md).

## Layer Responsibilities
| Layer | Owns | Never contains |
|---|---|---|
| `presentation/` | Widgets, screens, ViewModels, Riverpod providers, navigation, UI state | Business rules, plugin calls |
| `domain/` | Entities, UseCases, repository interfaces, business rules | Flutter imports, plugin references |
| `data/` | Repository implementations, data sources, plugin wrappers, DTOs/mappers | Business rules |
| `di/` | Dependency assembly only | Business logic |

## Shared Kernel (architecture-review addition)
`Album`, `Photo`, and `AppSettings` (canonically defined in
[`sdd/core/data/data-model.md`](../sdd/core/data/data-model.md)) are used by more than
one feature. They live in a project-level `lib/core/domain/` shared kernel, not inside
any single feature — see [folder_structure.md](folder_structure.md) and
[dependency_rules.md](dependency_rules.md) for the exact placement and import rules.

## Related Documents
- [folder_structure.md](folder_structure.md)
- [dependency_rules.md](dependency_rules.md)
- [feature_guidelines.md](feature_guidelines.md)
- [riverpod_mvvm.md](riverpod_mvvm.md)
- [dependency_injection.md](dependency_injection.md)
- [navigation_strategy.md](navigation_strategy.md)
- [state_management.md](state_management.md)
- [repository_pattern.md](repository_pattern.md)
- [testing_strategy.md](testing_strategy.md)
