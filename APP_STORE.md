# App Store 출시 준비 (Phase 5)

BeanDiary 1.0.0 App Store 제출 체크리스트입니다.  
**Mac + Apple Developer Program($99/년)** 이 필요합니다.

## 사전 준비물

| 항목 | 상태 | 비고 |
|------|------|------|
| Apple Developer 계정 | ⬜ | [developer.apple.com](https://developer.apple.com) |
| Bundle ID `com.beandiary.app` | ⬜ | Certificates, Identifiers 등록 |
| App Icon 1024×1024 | ✅ | `BeanDiary/Assets.xcassets/AppIcon.appiconset/AppIcon.png` |
| Privacy Manifest | ✅ | `BeanDiary/PrivacyInfo.xcprivacy` |
| 개인정보 처리방침 | ✅ | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| App Store 메타데이터 (한국어) | ✅ | `AppStore/metadata/ko/` |
| GitHub Actions 빌드 | ✅ | [Actions](https://github.com/aoa46789-alt/BeanDiary/actions) |

## 1. Mac에서 서명 설정

1. Xcode에서 `BeanDiary.xcodeproj` 열기
2. **BeanDiary** 타겟 → **Signing & Capabilities**
   - Team: 본인 Apple Developer 팀 선택
   - Bundle Identifier: `com.beandiary.app`
3. **BeanDiaryWidgets** 타겟도 동일 팀으로 서명
   - Bundle Identifier: `com.beandiary.app.widgets`
4. **Product → Archive** (Release 구성)

## 2. App Store Connect 앱 등록

1. [App Store Connect](https://appstoreconnect.apple.com) → **나의 앱** → **+**
2. 플랫폼: iOS, 이름: **BeanDiary**, 기본 언어: 한국어
3. Bundle ID: `com.beandiary.app` 선택
4. SKU: 예) `beandiary-ios-001`

### 메타데이터 복사

`AppStore/metadata/ko/` 파일 내용을 App Store Connect에 붙여넣기:

| 필드 | 파일 |
|------|------|
| 부제 | `subtitle.txt` |
| 키워드 | `keywords.txt` |
| 홍보용 텍스트 | `promotional_text.txt` |
| 설명 | `description.txt` |
| 버전 릴리스 노트 | `release_notes_1.0.0.txt` |

### 스크린샷 (필수)

iPhone 6.7" (1290×2796) 최소 3장 권장:

1. **홈** — 주간 통계
2. **기록** — 커피 로그 + 사진
3. **원두** — AI 분석 결과
4. **레시피** — YouTube + 브루잉 가이드
5. **지도** — 카페 핀·필터

시뮬레이터: **iPhone 16 Pro Max** → ⌘S로 저장

### 개인정보 (App Privacy)

App Store Connect → **앱 개인 정보 보호**:

| 항목 | 답변 |
|------|------|
| 데이터 수집 | **아니요** (개발자 서버 없음) |
| 추적 | **아니요** |
| 제3자 API | 사용자가 직접 입력한 API 키로 Google에 요청 |

개인정보 처리방침 URL:
`https://github.com/aoa46789-alt/BeanDiary/blob/main/PRIVACY_POLICY.md`

### 수출 규정

- 앱은 표준 HTTPS만 사용 → **암호화 면제** (`ITSAppUsesNonExemptEncryption = NO` 이미 설정됨)
- App Store Connect 제출 시 "암호화 사용" → **예**, "면제 대상" → **예**

### 연령 등급

- 질문지 작성 시 도박·폭력·의료 등 **없음**
- 예상: **4+**

### 카테고리

- 기본: **음식 및 음료** (Food & Drink)
- 보조: **라이프스타일** (선택)

## 3. TestFlight 배포

1. Xcode Organizer에서 Archive → **Distribute App**
2. **App Store Connect** → Upload
3. 처리 완료 후 TestFlight → 내부 테스트 추가
4. 실기기에서 API 키·카메라·지도·Live Activity 동작 확인

### 테스트 체크리스트

- [ ] 커피 기록 CRUD + 사진/영상
- [ ] Gemini 원두 분석 (API 키 입력)
- [ ] YouTube 레시피 검색·파싱
- [ ] 브루잉 가이드 + Live Activity
- [ ] 카페 지도 검색·필터·미리보기
- [ ] 오프라인 배너 (비행기 모드)
- [ ] 앱 삭제 후 데이터 제거 확인

## 4. 심사 제출

1. App Store Connect → **버전 1.0.0** → 빌드 선택
2. **심사에 제출**
3. 심사 메모 예시:

```
BeanDiary는 API 키를 사용자가 직접 입력하는 구조입니다.
테스트용 Gemini API 키: [본인 키 입력]
더보기 → 설정에서 입력 후 원두 탭 → AI 분석을 확인해 주세요.
YouTube 기능은 YouTube Data API v3 활성화된 동일 키를 사용합니다.
```

> ⚠️ 심사용 데모 API 키를 메모에 포함하거나, 키 없이도 동작하는 기록·지도 기능을 안내하세요.

## 5. Windows에서 할 수 있는 것

| 가능 | 불가능 |
|------|--------|
| 코드·메타데이터·Privacy Manifest 수정 | Archive / IPA 생성 |
| GitHub Actions 빌드 검증 | App Store Connect 업로드 |
| 스크린샷 편집 (디자인 툴) | 실기기 TestFlight 설치 |

Mac 접근 시: [BUILDING.md](BUILDING.md) 3절 참고

## 버전 정책

- **MARKETING_VERSION** (`CFBundleShortVersionString`): `1.0.0`
- **CURRENT_PROJECT_VERSION** (`CFBundleVersion`): 정수, 빌드마다 +1
- App Store 심사 통과 후 태그: `git tag v1.0.0 && git push origin v1.0.0`

## 문제 해결

| 오류 | 해결 |
|------|------|
| Signing 실패 | Xcode Team 재선택, Bundle ID 등록 확인 |
| Widget 서명 오류 | BeanDiaryWidgets 타겟 Team 일치 |
| Privacy Manifest 누락 | `PrivacyInfo.xcprivacy`가 Copy Bundle Resources에 포함됐는지 확인 |
| Live Activity 미표시 | 설정 → BeanDiary → Live Activity 허용 |

---

**다음 단계:** Apple Developer 계정이 준비되면 Mac에서 Archive → TestFlight → 심사 제출
