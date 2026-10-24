---
title: Data Model
category: core
status: mvp
owner: core
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Data Model

Verbatim entity fields from §15, with relationships made explicit.

## Album
| Field | Notes |
|---|---|
| `id` | App-local identifier |
| `systemAlbumId` | Reference to the actual device gallery album (DR-1) |
| `name` | Subject to duplicate-check scoped per DR-4 |
| `isVisibleInLoop` | Controls loop visibility ([feature/album/manage-album.md](../../feature/album/manage-album.md)) |
| `isSystemAlbum` | Drives default loop exclusion (DR-2) |
| `createdAt` | |
| `updatedAt` | |
| `lastUsedAt` | Drives "3 most recent albums" first-run display (§7) |
| `photoCount` | |

## Photo
| Field | Notes |
|---|---|
| `id` | |
| `albumId` | FK → `Album.id`; must resolve to a valid save target per DR-3 |
| `filePath` | |
| `createdAt` | |

## AppSettings
| Field | Notes |
|---|---|
| `selectedAlbumId` | FK → `Album.id`; persisted across restarts (DR-7) |
| `hasCompletedOnboarding` | Backs `AppLaunchState` |

## Relationships
```
Album (1) ──< (N) Photo         via Photo.albumId
Album (1) ──  (1) AppSettings   via AppSettings.selectedAlbumId
```

**Assumption (forward-compatibility note):** identifiers should remain stable/portable if
a future backend sync layer is introduced (see [be/future-scope.md](../../be/future-scope.md));
this is a design consideration, not a PDF-stated requirement.
