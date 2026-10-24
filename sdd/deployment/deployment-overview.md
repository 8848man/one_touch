---
title: Deployment Overview
category: deployment
status: mvp
owner: deployment
version: 1.0
source:
  - one_touch_plan_doc.pdf
---

# Deployment Overview

## MVP Deployment Scope
Since there is no backend, no server infrastructure requires deployment (§16). Deployment
scope is limited to standard mobile app packaging and distribution.

## Target
- Android app package, distributed via standard app store channels.
  **Assumption:** the PDF states Android is the primary platform (§16) but does not specify
  a distribution channel; Play Store distribution is the conventional default, not a
  PDF-stated fact.
- iOS packaging/distribution is deferred along with iOS platform support itself (§16).

## Not Applicable to MVP
- Backend deployment, environment provisioning, database migrations — none exist (see
  [be/future-scope.md](../be/future-scope.md)).
- Server-side CI/CD for API services.

## Open Items
**Assumption:** release cadence, CI/CD pipeline, and app-store review process are not
addressed in the source document. These should be defined by the engineering team
separately from this SDD and are flagged here as an open gap rather than invented.

## Future Consideration
Once backend responsibilities (cloud sync, shared albums) are prioritized (see
[be/future-scope.md](../be/future-scope.md)), this document will need a companion backend
deployment spec — deliberately not created yet.
