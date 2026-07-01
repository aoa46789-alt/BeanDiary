# GitHub 업로드 가이드 (aoa46789-alt)

계정: https://github.com/aoa46789-alt  
현재 **공개 저장소 0개** — `https://github.com/aoa46789-alt/-` 는 아직 만들어지지 않아 **404** 입니다.

## 1단계: GitHub에서 저장소 만들기

1. 로그인: https://github.com/aoa46789-alt
2. 우측 상단 **+** → **New repository**
3. 설정:
   - **Repository name:** `BeanDiary` ( `-` 대신 이 이름 권장)
   - **Public** 선택
   - README / .gitignore / license **추가하지 않음** (빈 저장소)
4. **Create repository** 클릭

만든 뒤 주소: `https://github.com/aoa46789-alt/BeanDiary`

## 2단계: 코드 올리기

### 방법 A — GitHub 웹 (Git 미설치 OK)

1. 새 저장소 페이지 → **uploading an existing file** 링크
2. `C:\Users\WOO\Projects\BeanDiary` 폴더 안 파일·폴더를 드래그:
   - `BeanDiary/` (Swift 소스)
   - `BeanDiary.xcodeproj/`
   - `.github/`
   - `scripts/`
   - `README.md`, `BUILDING.md`, `.gitignore`
3. Commit message: `BeanDiary Phase 1`
4. **Commit changes**

### 방법 B — Git 설치 후 (권장, Actions 자동 빌드)

1. 설치: https://git-scm.com/download/win
2. PowerShell:

```powershell
cd C:\Users\WOO\Projects\BeanDiary
git init
git add .
git commit -m "BeanDiary Phase 1"
git branch -M main
git remote add origin https://github.com/aoa46789-alt/BeanDiary.git
git push -u origin main
```

GitHub 로그인 창이 뜨면 승인합니다.

## 3단계: Actions로 Mac 빌드 확인

1. 저장소 → **Actions** 탭
2. **iOS Build** 워크플로 실행 확인
3. ✅ 초록색 = 빌드 성공  
   ❌ 빨간색 = **xcodebuild-log** 아티팩트 다운로드 → Cursor에 붙여넣기

## 저장소 이름을 `-` 로 꼭 쓰고 싶다면

GitHub에서 repo 이름 `-` 는 특수문자라 **권장하지 않습니다.** `BeanDiary` 또는 `bean-diary` 를 사용하세요.

## 다음에 알려주실 것

저장소를 만든 뒤 **정확한 URL** (예: `https://github.com/aoa46789-alt/BeanDiary`) 을 보내주시면:
- Actions 빌드 실패 로그 기준으로 코드 수정
- Phase 2 (Gemini) 진행

을 이어갈 수 있습니다.
