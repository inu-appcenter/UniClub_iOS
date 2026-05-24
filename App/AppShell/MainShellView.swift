import SwiftUI

struct MainShellView: View {
    @Environment(\.appMetrics) private var m
    @State private var tab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var qnaPath = NavigationPath()
    @State private var myPagePath = NavigationPath()
    @State private var isTabBarVisible = true

    private var tabBarHidden: Bool {
        if tab == .qna { return true }
        return !isTabBarVisible
    }

    /// 탭바가 화면에 보일 때 자식이 보상해야 할 하단 높이.
    /// 숨김 상태이면 0. 자식은 `@Environment(\.tabBarHeight)` 로 읽는다.
    private var tabBarBottomInset: CGFloat {
        tabBarHidden ? 0 : AppTabBarChrome.height(scale: m.scale)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            switch tab {
            case .home:
                NavigationStack(path: $homePath) {
                    HomeRootView(path: $homePath)
                }
                .onPreferenceChange(TabBarPresencePreferenceKey.self) { isTabBarVisible = $0 }

            case .mypage:
                NavigationStack(path: $myPagePath) {
                    MyPageView(path: $myPagePath)
                }
                .onPreferenceChange(TabBarPresencePreferenceKey.self) { isTabBarVisible = $0 }

            case .qna:
                NavigationStack(path: $qnaPath) {
                    QnARootView(
                        path: $qnaPath,
                        onBackToHome: {
                            qnaPath.removeLast(qnaPath.count)
                            tab = .home
                        }
                    )
                }
                .onPreferenceChange(TabBarPresencePreferenceKey.self) { isTabBarVisible = $0 }
            }

            AppTabBarChrome(
                selection: Binding(
                    get: { tab },
                    set: { newTab in
                        if tab == newTab {
                            switch newTab {
                            case .home:   homePath.removeLast(homePath.count)
                            case .qna:    qnaPath.removeLast(qnaPath.count)
                            case .mypage: myPagePath.removeLast(myPagePath.count)
                            }
                        }
                        tab = newTab
                        isTabBarVisible = true
                    }
                ),
                isHidden: tabBarHidden
            )
        }
        .environment(\.tabBarHeight, tabBarBottomInset)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("MainShellView") {
    MainShellView()
}
