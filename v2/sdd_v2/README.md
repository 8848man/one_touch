---
title: sdd_v2 — 인덱스
status: v2-prototype
version: 1.0
source:
  - reference/ (Figma 원터치카메라 프레임 캡처)
  - sdd/implementation-spec-v2.md (Figma 주석 분석)
  - sdd/ (MVP 명세 — 재사용분만 링크)
---

# sdd_v2

v2 프로토타입 명세. 일부러 가볍게 쓴다: 문서 6개, 결정은 표 한 줄로 끝낸다.
MVP 명세(`../../sdd/`)에서 바뀌지 않은 내용은 다시 쓰지 않고 링크한다.

## 문서

| 문서 | 내용 |
|---|---|
| [scope.md](scope.md) | 들어가는 기능 / 빠지는 기능, Open 항목에 대한 프로토타입 결정 |
| [domain-rules.md](domain-rules.md) | 앨범 규칙 (MVP 규칙 중 유지·변경분) |
| [data-model.md](data-model.md) | 엔티티와 로컬 저장 방식 |
| [screens.md](screens.md) | 화면별 동작 (카메라, 앨범 리스트, 다이얼로그, 설정, 폴더블) |
| [implementation-plan.md](implementation-plan.md) | 구현 순서와 진행 상태 |
| [../design_system/README.md](../design_system/README.md) | 디자인 토큰과 컴포넌트 |

## 우선순위

`reference/` 화면 + Figma 주석 > `sdd_v2/` > MVP `sdd/` > 코드.
화면과 명세가 다르면 명세를 고친다.

## MVP 명세 재사용

| MVP 문서 | v2에서 |
|---|---|
| `../../architecture/` 전체 | 그대로 따른다. 단, Riverpod 코드 생성은 쓰지 않는다 (손으로 쓴 `Notifier` provider) — 프로토타입 빌드 단순화 |
| `../../sdd/infra/` (camera, permissions, storage, platform) | 그대로. 동영상용 마이크 권한만 추가 ([screens.md](screens.md) §카메라) |
| `../../sdd/feature/album/save-flow.md` | 그대로 (저장 실패 시 안내) |
| `../../sdd/feature/onboarding/first-run-flow.md` | 단순화: 권한 요청 → 앨범 없으면 빈 상태에서 생성 유도 |
| `../../sdd/core/domain/domain-rules.md` | [domain-rules.md](domain-rules.md)가 대체 |
| `../../sdd/fe/*`, `screen_ref/` | 사용하지 않음 — `reference/`와 [screens.md](screens.md)가 대체 |
