---
title: v2 구현 계획
status: v2-prototype
version: 1.0
---

# 구현 계획

## 코드 구조

`architecture/`의 feature-first + Riverpod MVVM을 따르되 가볍게.

```
app/lib/
├─ main.dart
├─ app.dart                     # MaterialApp, 테마, 라우트
├─ design_system/               # 토큰·테마·공용 위젯 (design_system/README.md 구현체)
├─ core/
│  ├─ domain/                   # Album 엔티티, 저장소 인터페이스, 이름 규칙
│  ├─ data/                     # photo_manager / camera / permission / prefs 구현
│  └─ providers.dart            # 저장소 provider (root DI)
└─ features/
   ├─ camera/                   # 카메라 화면, 촬영·녹화, 썸네일
   ├─ albums/                   # 앨범 상태, 리스트 화면, 다이얼로그, 사진 그리드
   ├─ settings/                 # 설정 화면, 프리미엄 상태
   └─ shell/                    # 폴더블 분기, 권한 게이트
```

## 기존 앱에서 옮긴 것

| 기존 (`app/lib/`) | v2 |
|---|---|
| `camera_repository_impl.dart` | `core/data/camera_service.dart` (전후면 전환·녹화 추가) |
| `gallery_repository_impl.dart`의 `relativePath` 저장 방식 | `core/data/media_store.dart` (동영상 저장·조회 추가, 디버그 출력 제거) |
| `permission_repository_impl.dart` | `core/data/permission_service.dart` (마이크 추가) |
| `capture_and_save_provider.dart`의 중복 탭 잠금 | `features/camera/camera_controller.dart` |
| `android/` 설정 | applicationId·앱 이름 변경, 마이크 권한 추가 |

새로 만든 것: 앨범 저장소(JSON), 모든 화면, 디자인 시스템.

## 단계

| 단계 | 내용 | 상태 |
|---|---|---|
| 1 | sdd_v2, design_system 문서 | 완료 |
| 2 | 프로젝트 뼈대, android 설정, 데이터 계층 | 완료 (2~8은 코드 작성 기준) |
| 3 | 앨범 상태 + 앨범 리스트 (토글·정렬·이름 변경·삭제) | 완료 |
| 4 | 카메라 화면 (촬영·칩·썸네일·새 앨범) | 완료 |
| 5 | 동영상 녹화 | 완료 |
| 6 | 설정, 무료 제한 | 완료 |
| 7 | 폴더블 레이아웃 | 완료 |
| 8 | 단위 테스트 (이름 규칙, 앨범 상태) | 작성 완료 |
| 9 | `flutter pub get` / `analyze` / `test` | 빌드 통과 (Android Studio). 단위 테스트 2개 실패 → id 중복 버그 수정, 재실행 필요 |
| 10 | 에뮬레이터 확인 (2026-10-07, API 35) | 일부 완료 — 아래 체크리스트 |
| 11 | 기존 갤러리 앨범 가져오기 + 활성 앨범 3개 제한 (V15~V18, V13 변경) | 코드 작성 완료, 테스트·기기 확인 필요 |
| 12 | 개선 6건 (2026-10-23): 권한 안내 1장 + 마이크 지연 요청, 이름 탭 편집·휴지통, 실제 폴더 이름 변경(V7), 칩 하단 여백, 칩 끝 새 앨범 칩, 사진 다중 선택 이동·삭제(V19) | 코드 작성 완료, 빌드·기기 확인 필요 |

## 실기기 체크리스트

- [x] 첫 실행 권한 요청 (카메라, 사진·동영상, 마이크)
- [x] 앨범 만들기 → 칩 선택 이동 → 촬영 → 썸네일·사진 수 반영 (갤러리 앱 폴더 확인은 미실시)
- [ ] 칩 스와이프로 다른 앨범 저장 (칩 탭 선택은 확인, 스와이프는 미실시)
- [x] 동영상 녹화 → 같은 폴더 저장 (타이머·정지 버튼 확인)
- [ ] 리스트: 숨김 → 칩에서 사라짐 ✓, 사진 수 ✓, 드래그 정렬 미실시
- [ ] 이름 변경 / 삭제 (사진은 갤러리에 남는지)
- [x] 무료 4번째 앨범 차단 → 설정에서 프리미엄 체험 켜고 해제
- [ ] 폴더블 또는 태블릿 에뮬레이터에서 펼침 레이아웃
- [ ] 앱 재실행 시 마지막 촬영 앨범 선택
- [ ] 기존 앨범이 있는 기기에서 첫 실행 → 최근 앨범 3개가 켜지고 나머지는 리스트에 꺼진 채로 있음
- [ ] 가져온 앨범(예: Camera)에서 촬영 → 원래 폴더(DCIM/Camera)에 저장
- [ ] 무료 상태에서 4번째 스위치 켜기 → 안내 후 꺼진 상태 유지
- [ ] 가져온 앨범 삭제 → 앱을 다시 열어도 다시 생기지 않음
- [ ] 첫 실행: 안내 1장 → 카메라·사진 팝업 연달아 → 카메라 화면. 동영상 모드 처음 켤 때만 마이크 팝업
- [ ] 앨범 이름 탭 → 편집(✓, 휴지통) → 저장 시 확인 팝업 → 갤러리 앱에서 폴더 이름 바뀜
- [ ] 칩 끝 `[📔+]`로 새 앨범, 칩 아래 여백으로 내비게이션 바 오터치 없음
- [ ] 앨범 사진 길게 누르기 → 여러 장 선택 → 다른 앨범 이동 / 휴지통
