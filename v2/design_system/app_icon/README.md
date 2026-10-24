# 앱 아이콘 · 파비콘 후보

> **적용: A (2026-10-08).** B·C는 나중 옵션으로 보관한다 (삭제 금지).

`preview.png`에서 세 안을 비교한다. 색은 디자인 시스템 토큰(`primary #FB7F87`, `cameraSurface #231F1F`, `chipSelected #F8C6BF`)만 쓴다.

| 안 | 폴더 | 콘셉트 |
|---|---|---|
| A | `option_a_shutter_chip/` | 셔터 버튼 + 그 아래 선택된 앨범 칩. 앱의 카메라 화면을 그대로 축약한 형태 ("고르고 찍는다") |
| B | `option_b_album_lens/` | 앨범(폴더) 안에 렌즈. "찍으면 앨범으로"를 한 장에. 어두운 배경이라 홈 화면에서 눈에 띈다 |
| C | `option_c_one_tap/` | 터치 파동 + 숫자 1. 이름 "원터치"를 직접 표현. 작은 크기(16px)에서도 가장 읽기 쉽다 |

## 폴더 구성 (안마다 같음)

| 파일 | 용도 |
|---|---|
| `icon.svg` | 원본 (1024×1024, 정사각 풀블리드) |
| `adaptive_foreground.svg/_432.png`, `adaptive_background.svg/_432.png` | Android 적응형 아이콘 레이어 (그림은 가운데 안전 영역 안에 있음) |
| `android/mipmap-*/ic_launcher.png` | 레거시 런처 아이콘 48~192px |
| `playstore_512.png` | Play 스토어 등록용 |
| `favicon.ico` (16/32/48), `favicon-32.png`, `favicon-192.png` | 웹 파비콘 |

## 적용 방법 (선택 후)

1. 고른 안의 `android/mipmap-*/ic_launcher.png`를 `v2/app/android/app/src/main/res/mipmap-*/`에 덮어쓴다.
2. 적응형 아이콘까지 쓰려면 `mipmap-anydpi-v26/ic_launcher.xml`과 전경·배경 레이어를 추가한다 (선택 시 같이 작업).
3. 웹 빌드를 쓸 경우 `favicon-32.png` → `v2/app/web/favicon.png`, `favicon-192.png` → `web/icons/Icon-192.png`.
