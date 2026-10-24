---
title: Infra — Platform Support
category: infra
status: mvp
owner: infra
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Platform Support

## Platform Priority (§16)
- **Android: primary MVP target.**
- **iOS: deferred** (추후 — "later," not committed to a specific version in the source document).

## Implications
- The technical spike (§5) explicitly includes separate validation of Android and iOS
  support boundaries for gallery/album operations — these may not be symmetric.
- No login/auth infra is required on either platform (§16).
- No server-side infra is required (§16); all permission and storage APIs are on-device.

## Related Specs
- [infra/storage/gallery-storage-strategy.md](../storage/gallery-storage-strategy.md)
- [infra/camera/camera-integration.md](../camera/camera-integration.md)
- [deployment/deployment-overview.md](../../deployment/deployment-overview.md)
