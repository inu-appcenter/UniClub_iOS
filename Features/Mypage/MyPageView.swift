import SwiftUI

struct MyPageView: View {

    enum Route: Hashable {
        case notification
        case profileEdit
        case inquiry
        case deleteAccount
    }

    @Binding var isTabBarHidden: Bool

    @State private var path: [Route] = []
    @State private var showLogoutSheet: Bool = false
    @StateObject private var vm = MyPageViewModel()

    private let scrollSpace = "mypage.scroll"

    var body: some View {
        NavigationStack(path: $path) {
            // ✅ MyPage는 커스텀 헤더 성격 → topPadding 제거
            ScreenContainer(
                scroll: true,
                showsIndicators: false,
                background: AppColors.background,
                topPadding: .none,
                bottomPadding: .default
            ) { m in
                VStack(alignment: .leading, spacing: 0) {

                    // ✅ 헤더(타이틀)
                    Text("마이페이지")
                        .font(AppTypography.title())
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, m.space32 + m.space8)      // 40 근사 (토큰 조합)
                        .padding(.bottom, m.space24 + m.space2)   // 26 근사

                    // ✅ 프로필
                    MyPageProfileHeader(profile: vm.profileUI)
                        .padding(.bottom, m.space32 + m.space18 + m.space2) // 52 근사

                    // ✅ 계정
                    MyPageAccountSection(
                        onNotification: { path.append(.notification) },
                        onProfileEdit: { path.append(.profileEdit) },
                        onLogout: { showLogoutSheet = true }
                    )

                    MyPageDivider()
                        .padding(.vertical, m.space16)

                    // ✅ 이용안내
                    MyPageGuideSection(
                        onInquiry: { path.append(.inquiry) }
                    )

                    MyPageDivider()
                        .padding(.vertical, m.space16)

                    // ✅ 기타
                    MyPageEtcSection(
                        onDeleteAccount: { path.append(.deleteAccount) }
                    )

                    Spacer(minLength: m.space24)
                }
                .observeScrollDirection(
                    in: scrollSpace,
                    threshold: 6,
                    onScrollDown: { isTabBarHidden = true },
                    onScrollUp: { isTabBarHidden = false }
                )
                .coordinateSpace(name: scrollSpace)
            }
            .navigationDestination(for: Route.self) { r in
                switch r {
                case .notification:
                    NotificationSettingsView()

                case .profileEdit:
                    // ✅ 저장 성공 시 마이페이지 즉시 갱신
                    EditProfileView(onSaved: {
                        Task { await vm.refresh() }
                    })

                case .inquiry:
                    ContactUsView()

                case .deleteAccount:
                    DeleteAccountView()
                }
            }
            .overlay {
                if vm.isLoading {
                    ZStack {
                        Color.black.opacity(0.08).ignoresSafeArea()
                        ProgressView()
                    }
                }

                if let msg = vm.errorMessage, !msg.isEmpty {
                    // ✅ ScreenContainer의 horizontalPadding을 쓰고 있으므로
                    // 여기선 추가로 28 같은 숫자 금지
                    VStack(spacing: 10) {
                        Text(msg)
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Button("다시 시도") {
                            Task { await vm.load(force: true) }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(16)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                }

                if showLogoutSheet {
                    LogoutConfirmOverlay(
                        onCancel: { showLogoutSheet = false },
                        onConfirm: {
                            showLogoutSheet = false
                            path.removeAll()    // ✅ 네비 스택 리셋
                            vm.signOut()        // ✅ 루트 전환 트리거
                        }
                    )
                }
            }
        }
        .task {
            // ✅ 중복 로딩 방지 (v1.2 16.1)
            isTabBarHidden = false
            await vm.load(force: false)
        }
    }
}

#Preview("MyPageView") {
    MyPageView(isTabBarHidden: .constant(false))
}
