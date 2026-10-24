# One-Touch Camera v2 (프로토타입)

Figma `원터치카메라` 디자인을 기준으로 다시 만든 v2 앱. 백엔드가 없으므로 이 프로토타입이 곧 v2 MVP다.
기존 `app/`·`sdd/`는 건드리지 않고 이 폴더 안에서만 작업한다.

| 폴더 | 내용 |
|---|---|
| [`sdd_v2/`](sdd_v2/README.md) | v2 명세 (가볍게: 범위·규칙·데이터·화면·진행 순서) |
| [`design_system/`](design_system/README.md) | `reference/` 화면에서 뽑은 색·글자·간격·컴포넌트 규칙 |
| [`app/`](app/) | Flutter 앱 (패키지 `one_touch_camera_v2`, Android 전용) |

## 실행

```bash
cd v2/app
flutter pub get
flutter analyze
flutter test
flutter run            # Android 실기기 권장 (카메라·갤러리 저장 확인)
```

- 기존 앱과 같은 기기에 함께 설치되도록 applicationId를 `...one_touch_camera_v2`로 바꿨다.
- 코드 생성(build_runner)은 쓰지 않는다. `pub get` 후 바로 실행된다.
- 화면 레퍼런스: 저장소 루트의 `reference/` (Figma 프레임 캡처).

## 릴리스 빌드

```powershell
cd v2
powershell -ExecutionPolicy Bypass -File tools\build_release.ps1
```

결과: `releases/one_touch_v2-<버전>-release.apk`. 버전·이름·git 규칙은 [`AGENTS.md`](AGENTS.md)를 따른다.
