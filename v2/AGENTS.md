# AGENTS.md — v2 작업 규칙

`v2/` 폴더에서 일하는 AI 에이전트(Codex, Claude 등)가 지켜야 할 규칙. 제품·화면 명세는 [`sdd_v2/`](sdd_v2/README.md), 디자인은 [`design_system/`](design_system/README.md)을 따른다.

## 빌드 규칙

### 버전

- 버전은 `app/pubspec.yaml`의 `version: <이름>+<번호>` 한 곳에서만 바꾼다 (예: `2.2.0+3`).
  - 이름(`2.2.0`): 기능 추가는 가운데 자리, 버그 수정은 끝자리를 올린다.
  - 번호(`+3`): 빌드를 배포할 때마다 1씩 올린다. 줄이지 않는다.
- `android/local.properties`의 `flutter.versionName/versionCode`는 Flutter CLI가 자동으로 덮어쓰므로 손으로 고치지 않는다. Android Studio의 Run만으로 빌드하면 이 값이 옛 버전으로 남을 수 있으니, 배포용 빌드는 반드시 아래 스크립트(CLI)로 만든다.

### 배포용 APK 만들기

```powershell
cd D:\projects\one_touch\v2
powershell -ExecutionPolicy Bypass -File tools\build_release.ps1
```

스크립트가 하는 일:

1. `pubspec.yaml`에서 버전 이름을 읽는다.
2. `flutter build apk --release`를 실행한다.
3. 결과를 `releases/one_touch_v2-<버전 이름>-release.apk`로 복사한다 (예: `releases/one_touch_v2-2.2.0-release.apk`).

### 산출물 이름

| 종류 | 이름 | 위치 |
|---|---|---|
| 릴리스 APK | `one_touch_v2-<버전 이름>-release.apk` | `v2/releases/` |
| 디버그 APK | 공유하지 않는다 (느리고 용량이 2배) | `app/build/` (Flutter 기본 위치 그대로) |

- 같은 이름의 파일이 이미 있으면 스크립트가 멈춘다. 덮어쓰지 말고 `pubspec.yaml` 버전을 올린 뒤 다시 빌드한다.
- `app/build/app/outputs/flutter-apk/app-release.apk`는 중간 산출물이다. 공유는 `releases/`의 파일로 한다.

### 버전 관리 (git)

- `app/build/`, `releases/`, `*.apk`, `*.aab`는 커밋하지 않는다 (`.gitignore`에 등록됨).
- 배포한 APK는 git 대신 공유 드라이브나 GitHub Releases 같은 별도 저장소에 올린다.
- 버전을 올린 커밋에는 `pubspec.yaml` 변경만 포함하고, 메시지를 `chore: v2.2.0+3`처럼 쓴다.

### 하지 말 것

- `app/android/app/build.gradle.kts`에서 APK 파일 이름을 바꾸지 않는다. Flutter CLI가 `app-release.apk`라는 이름으로 결과를 찾기 때문에 빌드가 실패한다. 이름은 스크립트가 복사할 때 붙인다.
- 아이콘 후보 `design_system/app_icon/option_b_*`, `option_c_*`는 지우지 않는다 (나중에 옵션으로 쓸 예정).
