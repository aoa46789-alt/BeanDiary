# BeanDiary

스페셜티 커피 기록·분석 iOS 앱 (SwiftUI + SwiftData)

**Repository:** https://github.com/aoa46789-alt/BeanDiary  
**CI:** [Actions → iOS Build](https://github.com/aoa46789-alt/BeanDiary/actions)  
**App Store 준비:** [APP_STORE.md](APP_STORE.md)

## Mac이 없을 때

**[BUILDING.md](BUILDING.md)** 를 참고하세요.

1. Windows 검증: `powershell -ExecutionPolicy Bypass -File .\scripts\validate-project.ps1`
2. GitHub Actions: push하면 클라우드 Mac에서 자동 빌드

## 요구 사항

- **macOS + Xcode 16+** (로컬 실행·App Store 제출 시)
- **iOS 17+** (SwiftData, Live Activity)
- **버전:** 1.0.0

## 주요 기능

| 탭 | 기능 |
|----|------|
| 홈 | 주간/월간 통계, 최근 기록 |
| 지도 | 카페 검색·필터·AI 미리보기 |
| 기록 | 커피 로그 + 사진/영상 |
| 원두 | Gemini AI 분석, YouTube 레시피 |
| 더보기 | 설정, API 키, 타임라인 |

추가: 브루잉 스톱워치, Live Activity, EK43→C40 환산

## Xcode에서 열기 (Mac)

1. `BeanDiary.xcodeproj` 더블클릭
2. Signing Team 설정 (실기기·Archive 시)
3. iPhone 시뮬레이터 선택 → **Run** (⌘R)

## App Store 제출

[APP_STORE.md](APP_STORE.md) 체크리스트를 따르세요.

- 메타데이터: `AppStore/metadata/ko/`
- 개인정보 처리방침: [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
