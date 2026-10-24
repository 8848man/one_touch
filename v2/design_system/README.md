---
title: v2 디자인 시스템
status: v2-prototype
version: 1.0
source:
  - reference/*.png (색은 캡처에서 픽셀 샘플링, 크기는 360dp 프레임 기준 환산)
---

# 디자인 시스템

Figma 화면은 Material 3 구성(스위치, 다이얼로그, 떠 있는 pill 버튼)에 코랄 핑크 강조색을 얹은 형태다.
그래서 Material 3 `ThemeData`를 기반으로 하고 토큰만 덮어쓴다.
구현: `app/lib/design_system/` (`tokens.dart`, `theme.dart`, `widgets/`, 묶음 import는 `design_system.dart`).

> 캡처가 JPEG 축소본이라 색은 ±5 정도 오차가 있다. Figma 원본 값을 확인하면 `tokens.dart`만 고치면 된다.

## 1. 색

| 토큰 | 값 | 쓰임 | 레퍼런스 |
|---|---|---|---|
| `primary` | `#FB7F87` | 스위치 on, 선택 모드 아이콘 배경, 휴지통 버튼, 다이얼로그 버튼 글자 | 05, 03 |
| `primarySoft` | `#FDD0D3` | 연필 버튼, 새 앨범 버튼 배경 | 06, 05 |
| `primaryTint` | `#FFF5F6` | 스와이프로 열린 행 배경 | 06 |
| `chipSelected` | `#F8C6BF` | 선택된 앨범 칩 배경 | 01 |
| `cameraSurface` | `#231F1F` | 카메라 상단 바, 하단 컨트롤 영역, 리스트 상단 바 | 01, 05 |
| `onCamera` | `#FFFFFF` | 카메라 영역 아이콘·글자 | 01 |
| `onCameraMuted` | `#BDB7B6` | 선택 안 된 칩 글자 | 01 |
| `surface` | `#FFFFFF` | 리스트·설정·다이얼로그 배경 | 05 |
| `onSurface` | `#1D1B1B` | 본문 글자 | 05 |
| `onSurfaceMuted` | `#6F6A6A` | 사진 수, 보조 글자 | 05 |
| `switchOffTrack` | `#F2E9EA` | 스위치 off 트랙 | 05 |
| `switchOffThumb` | `#8F8586` | 스위치 off 손잡이·테두리 | 05 |
| `scrim` | `#000000` 50% | 다이얼로그 뒤 딤 | 11 |
| `recording` | `#E53935` | 녹화 중 표시 | 신규 |

## 2. 글자

시스템 기본 글꼴(Android: Roboto + Noto Sans KR). 화면의 위계는 다섯 단계면 충분하다.

| 토큰 | 크기 / 굵기 | 쓰임 |
|---|---|---|
| `title` | 18 / w600 | "앨범 리스트", 화면 제목 |
| `dialogTitle` | 22 / w400 | 다이얼로그 제목 |
| `body` | 15 / w400 | 앨범 이름, 설정 항목 |
| `label` | 13 / w500 | 앨범 칩, 버튼 |
| `caption` | 11 / w500 | 사진 수 `100+`, 상태바 수준 보조 |

## 3. 간격·크기·모서리

4dp 단위. 주요 값만 고정한다.

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `space.xs/s/m/l/xl` | 4 / 8 / 12 / 16 / 24 | 일반 간격 |
| `topBarHeight` | 56 | 상단 바 |
| `listRowHeight` | 56 | 앨범 행 |
| `chipBarHeight` | 48 | 앨범 칩 행 (아래에 16dp + SafeArea 여백) |
| `railWidth` / `expandedControlsWidth` | 56 / 104 | 폴더블 왼쪽 레일 / 오른쪽 컨트롤 |
| `shutterSize` | 72 (테두리 4) | 셔터 |
| `sideButtonSize` | 44 | 썸네일, 전후면 |
| `swipeActionWidth` | 48 | 연필·휴지통 버튼 (간격 4) |
| `radius.s/m/l/pill` | 8 / 12 / 28 / 999 | 버튼 / 행 / 다이얼로그 / 칩·pill 버튼 |

## 4. 컴포넌트

| 컴포넌트 | 파일 | 설명 | 레퍼런스 |
|---|---|---|---|
| `CameraTopBar` | `widgets/camera_buttons.dart` | 어두운 바, 왼쪽 아이콘 묶음 + 오른쪽 아이콘 | 01 |
| `ShutterButton` | `widgets/camera_buttons.dart` | 흰 원 + 흰 테두리 링. 녹화 중 빨간 둥근 사각형, 비활성 시 회색 | 01, 03 |
| `ModeToggle` | `widgets/camera_buttons.dart` | 사진/동영상 아이콘 2개, 선택 쪽 `primary` 원 배경 | 01 |
| `RoundIconButton` | `widgets/camera_buttons.dart` | 어두운 원형 버튼 (전후면 등) | 01 |
| `AlbumChipBar` | `widgets/album_chip_bar.dart` | 가로 스크롤 칩, 선택 칩 가운데 정렬 + 위 삼각형 표시, 스와이프 시 가장 가까운 칩에 스냅. `trailing` 자리에 `AlbumAddChip`(앨범 아이콘 + `+` 테두리 칩) | 01 |
| `PillButton` | `widgets/list_widgets.dart` | `primarySoft` 배경 pill, 아이콘 + 글자, 그림자 약하게 | 05 |
| `SwipeActionRow` | `widgets/list_widgets.dart` | 왼쪽 스와이프로 오른쪽 액션 버튼 노출, 열린 상태는 `primaryTint` | 06 |
| `AppDialog` | `widgets/app_dialog.dart` | 제목 + 본문/입력 + 오른쪽 정렬 텍스트 버튼 (`primary`) | 03, 11 |
| 스위치 | 테마 (`SwitchThemeData`) | on: `primary` 트랙 + 흰 손잡이 / off: `switchOffTrack` + 회색 손잡이·테두리 | 05 |

## 5. 모션

| 상황 | 값 |
|---|---|
| 칩 스냅 | 250ms easeOutCubic |
| 스와이프 행 열기/닫기 | 200ms easeOut |
| 촬영 플래시 | 흰 오버레이 0→0.6→0, 150ms |
| 다이얼로그 | Material 기본 |
