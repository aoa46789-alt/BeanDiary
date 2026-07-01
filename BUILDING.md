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
| Phase 2~4 | 예정 (Gemini, YouTube, 지도) |

## 알려진 제한

- iOS 앱은 **Apple SDK**가 필요해 Windows에서 직접 컴파일 불가
- 시뮬레이터 실행도 Mac + Xcode 필수
- GitHub Actions 무료 한도: private repo는 월 2,000분 (public은 무제한)
