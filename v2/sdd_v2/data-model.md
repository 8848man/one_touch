---
title: v2 데이터 모델
status: v2-prototype
version: 1.0
---

# 데이터 모델

모두 기기 로컬. `shared_preferences`에 JSON으로 저장한다 (프로토타입 규모라 DB 불필요).

## Album

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | String | 생성 시각 기반 고유값. 이름이 바뀌어도 그대로 |
| `folderName` | String | 기기 폴더(갤러리 버킷) 이름. 사진 수·목록을 이 이름으로 찾는다. 이름 변경 시 새 폴더 이름으로 바뀐다 (V7) |
| `displayName` | String | 화면에 보이는 이름. 이름 변경 대상 |
| `isVisible` | bool | 칩에 나오는지 (V3) |
| `sortOrder` | int | 리스트·칩 순서 (V12) |
| `createdAt` | DateTime | |
| `lastUsedAt` | DateTime? | 마지막 촬영 시각 (V9, V11) |
| `relativePath` | String? | 가져온 앨범의 기기 경로 (예: `DCIM/Camera/`). null이면 `Pictures/<folderName>/` (V1, V17). 이름 변경 시 같은 상위 경로의 새 폴더로 바뀐다 |
| `isImported` | bool | 기기 갤러리에서 가져온 앨범인지 (리스트 표시·삭제 처리 구분) |

키: `v2.albums` → `List<Album>` JSON.

`photoCount`는 저장하지 않는다. 화면에 나올 때 `photo_manager`로 해당 폴더의 사진+동영상 수를 센다.
표시: 0이면 숨김, 1~99는 숫자, 100 이상은 `100+`.

## AppPrefs

| 키 | 타입 | 설명 |
|---|---|---|
| `v2.selectedAlbumId` | String? | 마지막 촬영 앨범 (V11) |
| `v2.premium` | bool | 프리미엄 체험 스위치 (V13, 결제 없음) |
| `v2.galleryImported` | bool | 첫 가져오기를 마쳤는지 (V16) |
| `v2.dismissedFolders` | List<String> | 삭제한 가져온 앨범의 폴더 이름 (V18) |

## 미디어

저장된 사진·동영상은 앱이 따로 기록하지 않는다. 갤러리(MediaStore)가 원본이다.
- 사진: `PhotoManager.editor.saveImageWithPath(path, relativePath: <저장 경로>)`
- 동영상: `PhotoManager.editor.saveVideo(file, relativePath: <저장 경로>)`
- 저장 경로 = `relativePath ?? 'Pictures/<folderName>'`, 실패 시 `Pictures/<folderName>` (V17)
- 조회: `getAssetPathList(type: RequestType.common)`에서 이름이 `folderName`인 경로
- 가져오기: 같은 목록을 돌며 폴더별 사진 수와 최신 미디어 1개를 읽는다. 최신 미디어의 `relativePath`가 폴더 경로가 된다 (Android 10 미만에서는 절대 경로라 쓰지 않는다)
