//
//  MainShellView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
///
//  MainShellView.swift
//  UniClub
//

import SwiftUI

struct MainShellView: View {
    @State private var tab: AppTab = .home

    // ✅ 각 탭별 NavigationPath 보관
    @State private var homePath = NavigationPath()
    @State private var qnaPath = NavigationPath()
    @State private var myPagePath = NavigationPath()

    @State private var isTabBarHidden: Bool = false

    var body: some View {
        GeometryReader { geo in
            let m = AppMetrics.make(for: geo.size, baseWidth: 360)
            let bottomInset = geo.safeAreaInsets.bottom

            ZStack {
                switch tab {
                case .home:
                    NavigationStack(path: $homePath) {
                        HomeRootView(path: $homePath)
                    }

                case .qna:
                    NavigationStack(path: $qnaPath) {
                        QandAPlaceholderView()
                    }

                case .mypage:
                    NavigationStack(path: $myPagePath) {
                        MyPageView(isTabBarHidden: $isTabBarHidden)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                AppTabBarChrome(
                    selection: Binding(
                        get: { tab },
                        set: { newTab in
                            if tab == newTab {
                                // ✅ 같은 탭 다시 누르면 루트로
                                popToRoot(for: newTab)
                            }
                            tab = newTab
                        }
                    ),
                    isHidden: isTabBarHidden,
                    bottomInset: bottomInset
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .environment(\.appMetrics, m)
        }
    }

    // ✅ 루트로 이동
    private func popToRoot(for tab: AppTab) {
        switch tab {
        case .home:
            homePath.removeLast(homePath.count)
        case .qna:
            qnaPath.removeLast(qnaPath.count)
        case .mypage:
            myPagePath.removeLast(myPagePath.count)
        }
    }
}

/// 아직 QnA 화면이 없을 수 있으니, 빌드 깨지지 않게 임시 뷰
private struct QandAPlaceholderView: View {
    var body: some View {
        ScreenContainer(scroll: false) { _ in
            VStack {
                Text("QnA 탭을 준비중입니다. 조금만 기다려주세요.")
                Spacer()
            }
        }
    }
}

#Preview("MainShellView") {
    MainShellView()
}
