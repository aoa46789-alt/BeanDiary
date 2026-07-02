# Mac 없이 빌드·오류 확인하기

Windows만 있는 환경에서 BeanDiary iOS 앱을 검증하는 방법입니다.

## 1. Windows에서 프로젝트 구조 검증 (지금 가능)

PowerShell:

```powershell
cd C:\Users\WOO\Projects\BeanDiary
powershell -ExecutionPolicy Bypass -File .\scripts\validate-project.ps1
```

확인 항목:
- Swift 파일 ↔ Xcode `project.pbxproj` 일치
- 필수 파일 존재
- 중괄호 균형 등 기본 검사

## 2. GitHub Actions로 Mac 빌드 (권장)

Mac이 없어도 **GitHub 클라우드 Mac**에서 자동 빌드합니다.

1. GitHub에 저장소 생성 (예: `your-name/BeanDiary`)
2. 로컬에서 push:

```powershell
cd C:\Users\WOO\Projects\BeanDiary
git init
git add .
git commit -m "Initial BeanDiary Phase 1"
git branch -M main
git remote add origin https://github.com/YOUR_USER/BeanDiary.git
git push -u origin main
```

3. GitHub → **Actions** 탭 → **iOS Build** 워크플로 확인
4. 빌드 실패 시 `xcodebuild-log` 아티팩트에서 오류 로그 다운로드

오류 로그를 저에게 붙여넣으면 Windows에서도 수정할 수 있습니다.

## 3. Mac이 생겼을 때

1. `BeanDiary.xcodeproj` 열기
2. 시뮬레이터 선택 → Run (⌘R)
3. Signing Team 설정 (실기기 테스트 시)

## 현재 구현 상태

| Phase | 상태 |
|-------|------|
| Phase 1 | 커피 기록, 홈 통계, 타임라인 |
| Phase 1b | 사진·영상 첨부 |
| Phase 2 | Gemini AI 원두 분석 (API 키 설정 필요) |
| Phase 3 | YouTube 레시피 검색·재생·AI 파싱 + EK→C40 환산 |
| Phase 3d~f | 브루잉 스톱워치 + 시음 노트 |
| Phase 3e | Live Activity (잠금화면·다이나믹 아일랜드 브루잉 타이머) |
| Phase 4a | 카페 지도 (MapKit 검색, 필터, 좋아요/방문예정/숨김, AI 미리보기) |
| Phase 4b | 카페 미리보기 UI 고도화 (감성 배지, 태그, 캐시 표시) |
| Phase 4 | 오프라인 배너, AI/YouTube 캐시 활용 |

## Gemini API 키 설정 (Phase 2)

1. [Google AI Studio](https://aistudio.google.com/apikey)에서 API 키 발급
2. 앱 **더보기 → 설정 → Gemini API 키** 입력
3. **원두** 탭에서 원두 선택 → **AI 분석 시작**

분석 결과는 `CoffeeBean.analysisJSON`에 캐시되어 같은 원두 재조회 시 API 호출을 줄입니다.

> Firebase AI Logic으로 전환하려면 Firebase Console에서 iOS 앱을 등록하고 `GoogleService-Info.plist`를 추가하세요. (추후 지원)

## YouTube API 설정 (Phase 3)

1. [Google Cloud Console](https://console.cloud.google.com)에서 **YouTube Data API v3** 활성화
2. API 키 발급 (Gemini와 동일 키 사용 가능)
3. 앱 **더보기 → 설정 → YouTube API 키** 입력 (비워두면 Gemini 키 재사용)
4. **원두** → 원두 선택 → **YouTube 레시피 찾기** → 영상 **레시피 분석**

## 카페 지도 (Phase 4a)

1. **지도** 탭에서 주변 카페 확인 (샘플 데이터 + 직접 추가)
2. **+** 버튼 → 카페명 검색 → MapKit 결과에서 추가
3. 핀 탭 → **맛있었어요** / **방문 예정** / **숨기기**
4. 필터: 전체, 좋아요, 방문 예정, 콜럼버스, 드립 전문, 숨긴 곳
5. Gemini API 키 설정 시 **AI 미리보기** (콜럼버스·드립·방문예정 카페)
6. **Apple 지도** / **네이버 지도**로 길찾기

## Live Activity (Phase 3e)

1. **원두** → 레시피 분석 → **추출 가이드 시작** → **추출 시작**
2. 앱을 나가도 잠금화면·다이나믹 아일랜드에 단계별 타이머 표시
3. 일시정지/단계 변경 시 Live Activity 자동 갱신
4. iOS **설정 → BeanDiary → Live Activity** 허용 필요

## 오프라인 동작 (Phase 4)

- 원두 AI 분석·카페 미리보기·YouTube 검색은 **네트워크 필요**
- 이전에 불러온 분석/미리보기는 기기에 캐시되어 오프라인에서도 표시
- 오프라인 시 화면 상단에 안내 배너 표시

## 알려진 제한

- iOS 앱은 **Apple SDK**가 필요해 Windows에서 직접 컴파일 불가
- 시뮬레이터 실행도 Mac + Xcode 필수
- GitHub Actions 무료 한도: private repo는 월 2,000분 (public은 무제한)
