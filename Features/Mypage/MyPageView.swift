import SwiftUI

struct MyPageView: View {

    enum Route: Hashable {
        case notification
        case profileEdit
        case inquiry
        case deleteAccount
    }

    @Binding var path: NavigationPath
    @Binding var isTabBarHidden: Bool

    @State private var showLogoutSheet: Bool = false
    @StateObject private var vm = MyPageViewModel()

    private let scrollSpace = "mypage.scroll"

    var body: some View {
        ScreenContainer(
            scroll: true,
            showsIndicators: false,
            background: AppColors.background,
            topPadding: .none,
            bottomPadding: .default
        ) { m in
            VStack(alignment: .leading, spacing: 0) {

                Text("마이페이지")
                    .font(AppTypography.title())
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, m.space32 + m.space8)
                    .padding(.bottom, m.space32 + m.space8)

                MyPageProfileHeader(profile: vm.profileUI)
                    .padding(.bottom, m.space24 + m.space4)

                MyPageDivider()
                    .padding(.bottom, m.space16)

                MyPageAccountSection(
                    onNotification: { path.append(Route.notification) },
                    onProfileEdit: { path.append(Route.profileEdit) },
                    onLogout: { showLogoutSheet = true }
                )

                MyPageDivider()
                    .padding(.vertical, m.space16)

                MyPageGuideSection(
                    onInquiry: { path.append(Route.inquiry) }
                )

                MyPageDivider()
                    .padding(.vertical, m.space16)

                MyPageEtcSection(
                    onDeleteAccount: { path.append(Route.deleteAccount) }
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
                        path.removeLast(path.count)
                        vm.signOut()
                    }
                )
            }
        }
        .task {
            isTabBarHidden = false
            await vm.load(force: false)
        }
    }
}

#Preview("MyPageView") {
    NavigationStack {
        MyPageView(
            path: .constant(NavigationPath()),
            isTabBarHidden: .constant(false)
        )
    }
}
