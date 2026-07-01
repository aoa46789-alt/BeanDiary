# BeanDiary

커피 기록·분석 iOS 앱 (SwiftUI + SwiftData)

## Mac이 없을 때

**[BUILDING.md](BUILDING.md)** 를 참고하세요.

1. Windows 검증: `powershell -ExecutionPolicy Bypass -File .\scripts\validate-project.ps1`
2. GitHub Actions: push하면 클라우드 Mac에서 자동 빌드

## 요구 사항

- **macOS + Xcode 16+** (로컬 실행 시)
- **iOS 17+** (SwiftData)

## Xcode에서 열기 (Mac)

1. `BeanDiary.xcodeproj` 더블클릭
2. iPhone 시뮬레이터 선택 → **Run** (⌘R)

## Phase 1 완료 기능

- **홈**: 마지막 커피, 이번 주/달 잔 수
- **기록**: 원두·추출·평점·시음 메모 + 사진/영상
- **타임라인**: 날짜별 기록, 미디어 재생
- **원두 목록**, **지도**(Phase 4 예정)
