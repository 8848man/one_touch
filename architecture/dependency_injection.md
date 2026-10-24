---
title: Dependency Injection
category: architecture
status: mvp
owner: architecture
version: 1.0
source: []
---

# Dependency Injection

## Two Tiers (architecture-review clarification)
The locked spec describes both a per-feature `di/` and an "orchestration layer" — these
are two distinct tiers, not one:

| Tier | Location | Responsibility |
|---|---|---|
| Root composition | `lib/di/app_providers.dart` | Binds `core/domain/` repository interfaces to their `data/` implementations as app-wide singletons (e.g. one `AlbumRepository` instance shared by `camera` and `album` features) |
| Feature-local wiring | `features/<name>/di/` | Constructs that feature's own UseCases and ViewModel providers, consuming the root-provided repositories |

## Root DI Responsibilities
- Instantiate each `data/` repository implementation exactly once (singleton Riverpod
  provider).
- Bind it to the `domain/` interface it satisfies.
- Nothing else — no business logic, no UI state.

## Feature DI Responsibilities
- Construct UseCases, injecting root-provided repositories.
- Expose the feature's ViewModel provider(s) for `presentation/` to consume.

## Illustrative Pattern (not production code)
```dart
// lib/di/app_providers.dart (root)
final albumRepositoryProvider = Provider<AlbumRepository>(
  (ref) => AlbumRepositoryImpl(photoManager: PhotoManagerDataSource()),
);

// features/album/di/album_providers.dart (feature-local)
final createAlbumUseCaseProvider = Provider(
  (ref) => CreateAlbumUseCase(ref.watch(albumRepositoryProvider)),
);
```

## Rules
1. Neither `presentation/` nor `domain/` ever constructs a repository implementation
   directly — only `di/` does, at either tier.
2. A feature's `di/` may depend on root `di/`'s exposed providers; the root `di/` never
   depends on any feature's `di/`.
3. Test doubles are substituted at the `di/` boundary (see [testing_strategy.md](testing_strategy.md)),
   not by modifying `domain/` or `presentation/` code.

## Related Documents
- [dependency_rules.md](dependency_rules.md)
- [repository_pattern.md](repository_pattern.md)
