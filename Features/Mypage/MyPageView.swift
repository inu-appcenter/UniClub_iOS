import SwiftUI

struct MyPageView: View {

    enum Route: Hashable {
        case notification
        case profileEdit
        case inquiry
        case deleteAccount
    }

    @Binding var path: NavigationPath

    @State private var showLogoutSheet: Bool = false
    @StateObject private var vm = MyPageViewModel()

    @Environment(\.appMetrics) private var m

    var body: some View {
        ScreenContainer(
            scroll: true,
            showsIndicators: false,
            background: AppColors.background,
            topPadding: .none,
            bottomPadding: .default
        ) { m in
            VStack(alignment: .leading, spacing: 0) {

                AppPageHeader {
                    Text("마이페이지")
                }
                .padding(.bottom, m.scale * 30)

                MyPageProfileHeader(profile: vm.profileUI)
                    .padding(.bottom, m.space28)

                MyPageDivider()
                    .padding(.bottom, m.space28)

                MyPageAccountSection(
                    onNotification: { path.append(Route.notification) },
                    onProfileEdit: { path.append(Route.profileEdit) },
                    onLogout: { showLogoutSheet = true }
                )

                MyPageDivider()
                    .padding(.top, m.space16)
                    .padding(.bottom, m.space28)

                MyPageGuideSection(
                    onInquiry: { path.append(Route.inquiry) }
                )

                MyPageDivider()
                    .padding(.top, m.space16)
                    .padding(.bottom, m.space28)

                MyPageEtcSection(
                    onDeleteAccount: { path.append(Route.deleteAccount) }
                )

                Spacer(minLength: m.space24)
            }
        }
        .navigationDestination(for: Route.self) { r in
            switch r {
            case .notification:
                NotificationSettingsView()
                    .tabBarPresent(false)

            case .profileEdit:
                EditProfileView(onSaved: {
                    Task { await vm.refresh() }
                })
                .tabBarPresent(false)

            case .inquiry:
                ContactUsView()
                    .tabBarPresent(false)

            case .deleteAccount:
                DeleteAccountView()
                    .tabBarPresent(false)
            }
        }
        .overlay {
            if vm.isLoading {
                ZStack {
                    AppColors.grey800.opacity(0.08).ignoresSafeArea()
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
                .padding(m.space16)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: m.radius12))
                .padding(.horizontal, m.space16)
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
            await vm.load(force: false)
        }
    }
}

#Preview("MyPageView") {
    NavigationStack {
        MyPageView(path: .constant(NavigationPath()))
    }
}
