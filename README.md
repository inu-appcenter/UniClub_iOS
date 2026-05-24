# UniClub iOS — 아키텍처 정책

이 문서는 UniClub iOS 앱의 **계층 구조와 각 계층의 책임 범위**를 명시합니다.
새 화면/컴포넌트를 추가하거나 기존 코드를 수정할 때 이 정책을 따릅니다.

> 핵심 원칙: **위→아래만 의존, 같은 계층 충돌 금지, 각 계층은 자기 책임만 수행**

---

## 계층 구조 (7계층)

```
┌─────────────────────────────────────────────────────┐
│ 1. App Bootstrap   (UniClubApp)                     │
├─────────────────────────────────────────────────────┤
│ 2. Shell / Navigation  (MainShellView, AuthRootView)│
├─────────────────────────────────────────────────────┤
│ 3. Screen Container  (ScreenContainer)              │
├─────────────────────────────────────────────────────┤
│ 4. Screen Chrome   (AppPageHeader)                  │
├─────────────────────────────────────────────────────┤
│ 5. UI Components   (IconButton, UniToggle 등)       │
├─────────────────────────────────────────────────────┤
│ 6. Design Tokens   (AppColors, AppTypography,       │
│                     AppMetrics)                     │
├─────────────────────────────────────────────────────┤
│ 7. Features        (HomeView, MyPageView,           │
│                     ViewModels, Services)           │
└─────────────────────────────────────────────────────┘
```

---

## 1. App Bootstrap

**파일**: `App/UniClubApp.swift`, `App/AppDelegate.swift`

### 책임
- 진입점(`@main`) 정의
- `GeometryReader`로 `AppMetrics` 생성 후 환경값 주입
- 인증 상태(`MyAuthStore.accessToken`)에 따른 루트 분기 (`MainShellView` vs `AuthRootView`)
- 전역 컬러 스킴 (`.preferredColorScheme(.light)`)

### 위임 (하지 않는 것)
- 화면별 패딩, 헤더, 탭바, 콘텐츠 렌더링
- 비즈니스 로직, 라우팅 세부사항
- **전역 safe area 무시** — 부모에 `.ignoresSafeArea(.top)`을 두면 NavigationStack 없는 자식(예: AuthRootView 분기 화면)으로 의도치 않게 전파되어 헤더가 상태바 뒤로 묻힌다. **safe area 확장이 필요한 화면이 자체적으로 호출**한다.

### Safe area 세부 정책

UniClubApp은 전역 ignoresSafeArea를 두지 않는다. 자식 화면은 자기 필요에 따라 명시적으로 호출한다.

| 위치 | 허용/금지 | 설명 |
|---|---|---|
| `ScreenContainer` 사용 화면 | safe area 직접 호출 금지 | 컨테이너가 background/하단을 자동 처리, 상단은 자연 존중 |
| ScreenContainer 미사용 화면(예: 피그마가 상태바 포함 좌표인 LoginView) | ScrollView에 `.ignoresSafeArea(.container, edges: .top)` 허용 | 자체 ScrollView 콘텐츠가 상태바 뒤까지 확장돼야 할 때만 |
| 오버레이 dim 배경 (`Color.opacity(...).ignoresSafeArea()`) | 허용 | 모달/시트의 dim 배경은 전체 화면 덮어야 함 |
| Feature의 `safeAreaTop` 직접 계산 (`UIApplication.shared...safeAreaInsets.top`) | **절대 금지** | UIKit 직접 접근 = 정책 우회 |
| ScreenContainer 안에서 `AppColors.background.ignoresSafeArea()` 추가 | **금지 — 중복** | 컨테이너가 이미 동일 처리 중 |
| App 레벨(`UniClubApp`)에 `.ignoresSafeArea(.top)` 추가 | **금지** | NavigationStack 없는 분기에서 자식 헤더가 상태바에 묻힘 |

---

## 2. Shell / Navigation

**파일**: `App/AppShell/MainShellView.swift`, `App/AppShell/AppTab.swift`,
`Features/Auth/AuthRootView.swift`, `Features/Home/HomeRootView.swift`,
각 Feature의 `*Route.swift`

### 책임
- 탭바 노출/숨김 (`AppTabBarChrome`, `TabBarPresencePreferenceKey`)
- 탭별 `NavigationStack` 관리, `NavigationPath` 보유
- 라우트 enum 정의 (`HomeRoute`, `MyPageView.Route` 등)
- 푸시/팝, `navigationDestination` 매핑
- **하단 탭바 영역(88pt) 보상 책임** — 하위 화면에 환경값/safeAreaInset으로 전달

### 위임 (하지 않는 것)
- 화면 콘텐츠 렌더링, 패딩
- 헤더 UI

### 규칙
- 화면(7계층)이 탭바 높이를 알 필요 없도록 셸에서 처리
- 새 라우트 추가 시 반드시 라우트 enum에 등록 (직접 view push 금지)

---

## 3. Screen Container

**파일**: `DesignSystem/Tokens/ScreenContainer.swift`

### 책임
- **좌우 패딩 단일 적용** (`horizontalPadding` = 18pt)
- 상하 가장자리 패딩 (`topPadding`, `bottomPadding`: `.default` / `.none` / `.custom`)
- 배경 색상 (`background`, 기본값 `AppColors.background`)
- 스크롤 여부 (`scroll: Bool`)
- 키보드 회피 (`keyboardAvoiding()`)
- 콘텐츠 최대 너비 제한 (`contentMaxWidth`)
- 하단 safe area 무시 (`.ignoresSafeArea(edges: .bottom)`)

### 위임 (하지 않는 것)
- 헤더, 뒤로가기 버튼
- 탭바 영역 보상 (2계층 책임)
- 콘텐츠 비즈니스 로직

### 규칙 (중요)
- **7계층(Feature)에서 `.padding(.horizontal, ...)` 추가 금지** — 좌우 패딩은 컨테이너만
- **7계층에서 `.background(AppColors.background)` 추가 금지** — 컨테이너 기본값 사용
- 헤더가 있는 화면은 `topPadding: .none`으로 설정하고 4계층(AppPageHeader)을 직접 배치

---

## 4. Screen Chrome (Header / Footer)

**파일**: `DesignSystem/Components/AppPageHeader.swift`

### 책임
- 상단 헤더: 뒤로가기, 중앙 타이틀, trailing 액션 슬롯
- 높이: `controlHeight44 + space4` = 48pt
- 음수 horizontal padding으로 부모 컨테이너의 18pt를 상쇄해 화면 가장자리까지 확장

### 위임 (하지 않는 것)
- 화면 콘텐츠
- safe area 직접 계산 (`safeAreaTop` 등 사용 금지)

### 규칙
- **푸시된 화면은 무조건 `AppPageHeader` 사용** — 자체 `IconButton.back` 직접 배치 금지
- **탭 루트 화면(`HomeView`, `MyPageView`)은 인라인 헤더 허용** — 단 디자인 토큰 사용
- center 슬롯이 비는 경우 `{ }` 빈 ViewBuilder로 처리 (signup 등)
- trailing이 비는 경우 convenience init 사용

---

## 5. UI Components

**파일**: `DesignSystem/Components/*.swift`,
각 Feature의 `Components/*.swift`

### 책임
- 자기완결적 위젯 (버튼, 토글, 카드, 입력 필드, 시트 등)
- 외부 의존 최소화 (필요한 데이터는 init에서 받음)
- 디자인 토큰(6계층)만 참조

### 위임 (하지 않는 것)
- 비즈니스 로직, 네트워킹
- 라우팅 (콜백으로 위임)

### 규칙
- DesignSystem 하위는 어떤 Feature에도 의존하지 않음
- Feature 하위 Components는 해당 Feature 내에서만 재사용

---

## 6. Design Tokens

**파일**: `DesignSystem/Tokens/AppColors.swift`, `AppTypography.swift`,
`AppMetrics.swift`, `AppTokens.swift`

### 책임
- **순수 값만 노출** — 동작 없음
- 색상 (`AppColors.brand`, `.background`, `.grey800` 등)
- 타이포 (`AppTypography.notoSans(_:weight:)`, semantic aliases)
- 사이즈/간격 (`AppMetrics.space18`, `.controlHeight44` 등 — scale 자동 적용)
- 반경 (`.radius12`, `.radiusBanner` 등)

### 위임 (하지 않는 것)
- 뷰 렌더링
- 상태/로직

### 규칙
- **7계층(Feature)에서 매직 넘버 사용 금지** — `31 * m.scale` 대신 적절한 토큰 사용
- 토큰에 없는 값이 반복 등장하면 토큰 추가
- 피그마 정확값이 필요한 일회성 케이스만 raw 값 허용 (주석 필수)

---

## 7. Features

**파일**: `Features/*/*.swift` (View, ViewModel, Service, Model)

### 책임
- 비즈니스 로직, 데이터 페치, 상태 관리
- 위 1~6 계층의 **조합만** 수행
- ViewModel (`@MainActor`, `ObservableObject`), Service (네트워크), Model (Codable)

### 위임 (하지 않는 것)
- 좌우 패딩 (3계층), 배경 (3계층), 탭바 보상 (2계층)
- 자체 헤더 컴포넌트 만들기 (4계층 사용)
- safe area 직접 계산
- 디자인 토큰 우회 (raw 매직 넘버)

---

## 의존 규칙

```
1 App  →  2 Shell  →  3 Container  →  4 Chrome
                          ↓              ↓
                          └──→ 5 Components ──→ 6 Tokens
                                    ↑              ↑
                                    └─── 7 Features ┘
```

- 위→아래 단방향만 허용
- 같은 계층끼리는 의존 가능 (예: Components 간 조합)
- **아래→위 의존 절대 금지** (예: Tokens가 Feature를 import할 수 없음)

---

## 단일 책임 매핑 (Single Responsibility Map)

**각 관심사(concern)는 오직 한 계층에서만 처리한다.** 다른 계층에서 같은 처리를 추가하는 것은 정책 위반(중복).

| 관심사 | 책임 계층 | 적용 방법 | 다른 계층에서 금지 |
|---|---|---|---|
| 좌우 패딩 (18pt) | **3. Container** | `ScreenContainer.horizontalPadding` 자동 | Feature에서 `.padding(.horizontal, ...)` 추가 금지 |
| 화면 배경색 | **3. Container** | `ScreenContainer.background` (기본 `AppColors.background`) | Feature에서 `.background(...)` 중복 금지 |
| 상단 safe area | **자연 존중** (App 레벨 무시 X) | 자동 (필요 화면만 자체 `.ignoresSafeArea(.container, edges: .top)` 호출) | UniClubApp/Feature에서 `safeAreaTop` 직접 계산 금지, App 레벨 전역 ignore 금지 |
| 하단 safe area | **3. Container** | `ScreenContainer`의 `.ignoresSafeArea(edges: .bottom)` | Feature에서 별도 처리 금지 |
| 탭바 영역 보상 (88pt) | **2. Shell** | `MainShellView`가 환경값/`safeAreaInset`으로 전달 | Feature에서 `.padding(.bottom, 89 * m.scale)` 금지 |
| 키보드 회피 | **3. Container** | `ScreenContainer.keyboardAvoiding()` 자동 | Feature에서 별도 modifier 금지 |
| 콘텐츠 최대 너비 | **3. Container** | `ScreenContainer.contentMaxWidth` 자동 | Feature에서 `.frame(maxWidth:)` 제한 금지 |
| 상단 헤더 (뒤로가기/타이틀) | **4. Chrome** | `AppPageHeader` | Feature에서 자체 `IconButton.back` + 패딩 금지 |
| 탭바 자체 | **2. Shell** | `AppTabBarChrome` | Feature에서 탭바 그리기 금지 |
| 라우트/네비게이션 | **2. Shell** | Route enum + `navigationDestination` | Feature에서 직접 view push 금지 |
| 색상 값 | **6. Tokens** | `AppColors.*` | Feature에서 `Color(hex:)`, `Color(red:)` 직접 사용 금지 |
| 폰트 | **6. Tokens** | `AppTypography.*` semantic alias 우선 | Feature에서 `.font(.system(size:))` 금지 |
| 간격/사이즈 값 | **6. Tokens** | `AppMetrics.space*`, `.controlHeight*` | Feature에서 raw 매직 넘버 금지 |
| 반경 | **6. Tokens** | `AppMetrics.radius*` | Feature에서 raw 매직 넘버 금지 |
| 비즈니스 로직 | **7. Features** | ViewModel + Service | View가 직접 네트워크 호출 금지 |

### 위반 발견 시 조치

1. **위반된 줄을 제거** — 책임 계층이 이미 처리 중이므로 단순 삭제
2. **인프라가 부족하면 책임 계층에 기능 추가** (예: 탭바 환경값 미존재 시 Shell에 추가)
3. **README의 단일 책임 매핑 갱신** — 새로운 인프라 반영

---

## 마이그레이션 / 정리 순서

기존 코드의 정책 위반을 정리할 때는 아래 순서로 진행한다. **위 계층의 인프라가 준비된 후 아래 계층의 위반을 정리**해야 회귀 위험이 적다.

### Step 1 — 책임 계층의 인프라 보강 (위→아래)
필요한 기능이 책임 계층에 없다면 먼저 추가.

- 예: 탭바 보상을 Shell이 책임지려면, Shell에 환경값(`TabBarSafeAreaKey` 등) 또는 `safeAreaInset` 주입 필요
- 예: 헤더를 4계층이 모두 책임지려면, `AppPageHeader`에 필요한 convenience init 추가

### Step 2 — 책임 계층의 단일 source 보장
같은 처리가 여러 곳에 흩어져 있다면 책임 계층으로 통합.

- 예: ScreenContainer의 `horizontalPadding`이 항상 18pt 적용되는지 확인
- 예: UniClubApp의 safe area 정책이 모든 경로에 적용되는지 확인

### Step 3 — 하위 계층(주로 Features)의 중복 제거
책임 계층이 이미 처리하고 있는 것을 Features에서 다시 하고 있다면 삭제.

- 단순 1~2줄 삭제가 대부분 (예: `.background(AppColors.background)` 제거)
- 시각적 회귀 확인 필수 — 책임 계층이 정말 같은 값을 제공하는지

### Step 4 — 매직 넘버 → 토큰 치환 (기계적)
토큰이 이미 있는 값(`space8`, `space14` 등) → 토큰 사용으로 치환.
토큰 없는 반복 값 → 토큰 추가 후 치환.
일회성 Figma 값 → raw 유지 + 주석.

### Step 5 — 헤더/Chrome 통일 (Layer 4)
3패턴(AppPageHeader / 인라인 Text / 자체 IconButton.back) → AppPageHeader로 수렴.
탭 루트 화면만 예외적으로 인라인 헤더 허용.

### Step 6 — 안티패턴 audit
README의 안티패턴 섹션 기준으로 전 화면 grep 후 일괄 제거.

---

## 신규 화면 추가 체크리스트

새 화면을 만들 때 아래 순서로 결정:

1. **라우트 등록** — 해당 Feature의 Route enum에 case 추가, `navigationDestination` 매핑
2. **컨테이너 선택** — `ScreenContainer` 사용. `topPadding`은 헤더 유무로 결정:
   - 헤더 있음 → `topPadding: .none` + `AppPageHeader`
   - 헤더 없음 → `topPadding: .default`
3. **콘텐츠 배치** — VStack 등으로 콘텐츠만 작성
   - 좌우 패딩 추가 ❌
   - 배경 색상 추가 ❌
   - 탭바 89pt 보상 추가 ❌
4. **토큰 사용** — 매직 넘버 대신 `AppMetrics.space*`, `AppColors.*` 사용
5. **상태/네트워킹** — ViewModel/Service로 분리

---

## 안티패턴 (피해야 할 코드)

```swift
// ❌ 7계층에서 좌우 패딩 추가
ScreenContainer { _ in
    VStack { ... }
        .padding(.horizontal, m.space8)  // ScreenContainer가 이미 18pt 적용 중
}

// ❌ 7계층에서 safe area 직접 계산
private var safeAreaTop: CGFloat { ... }
IconButton.back { ... }.padding(.top, safeAreaTop + 18)

// ❌ 7계층에서 탭바 보상 매직 넘버
.padding(.bottom, 89 * m.scale)

// ❌ 7계층에서 배경 중복
ScreenContainer { _ in
    ScrollView { ... }
        .background(AppColors.background)  // 이미 컨테이너가 깔았음
}

// ❌ Tokens가 raw 매직 넘버 노출
.padding(.leading, 31 * m.scale)  // → 토큰화 필요
```

---

## 변경 이력

- 2026-05-23: 초안 작성 (7계층 정책 수립)
- 2026-05-24: 단일 책임 매핑 + 마이그레이션 순서 추가
- 2026-05-24: Layer 1 safe area 세부 정책 + ScreenContainer `horizontalPadding` 옵션 추가, Signup1/2/3 ScreenContainer 통합
- 2026-05-24: UniClubApp의 전역 `.ignoresSafeArea(.top)` 제거 (NavigationStack 없는 분기로 의도치 않게 전파되는 문제 해결)
