---
title: Album — Save Flow (Success & Failure)
category: feature
status: mvp
owner: feature
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Save Flow

## Success Path (§11)
On successful save, feedback is limited to **one** of:
- brief screen-brightness increase, or
- short flash effect.

Explicitly **not** provided on success: preview, "saved" toast, result popup. This is a
deliberate minimalism choice — do not add any confirmation UI beyond the flash/brightness cue.

## Failure Path (§12)
### Trigger conditions
- Insufficient storage space.
- Storage permission problem.
- File creation failure.

### Flow
```
Error occurs
        ↓
Modal shown with message, e.g.:
  "저장 공간이 부족합니다." / "사진 저장에 실패했습니다."
        ↓
User taps confirm
        ↓
Camera screen remains active (no navigation away)
```

## Acceptance Criteria
1. Success feedback must never include a persisted UI element (toast/popup) — it is
   transient only (flash/brightness).
2. Failure modal always returns the user to the same camera screen state they were in
   before capture; the failed capture is not silently retried.
3. The album selection active at time of capture is what determines the save target —
   see [feature/album/album-loop.md](album-loop.md).

## Related Specs
- [feature/camera/shooting-flow.md](../camera/shooting-flow.md)
- [fe/ux/interaction-patterns.md](../../fe/ux/interaction-patterns.md) — flash/pulse animation spec
- [infra/storage/gallery-storage-strategy.md](../../infra/storage/gallery-storage-strategy.md) — underlying failure causes
