//
//  HomeRootView.swift
//  UniClub
//

import SwiftUI

struct HomeRootView: View {
    @Binding var path: NavigationPath
    @State private var showSearch = false

    var body: some View {
        ZStack {
            HomeView(
                onTapAll: { path.append(HomeRoute.clubListAll) },
                onTapCategory: { name in path.append(HomeRoute.clubListCategory(name)) },
                onTapSearch: { withAnimation(.easeInOut(duration: 0.25)) { showSearch = true } },
                onTapClub: { clubId in path.append(HomeRoute.promotionDetail(clubId)) },
                onTapNotification: { path.append(HomeRoute.notification) }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .clubListAll:
                    ClubListView(mode: .all)
                        .tabBarPresent(false)

                case .clubListCategory(let name):
                    ClubListView(mode: .category(name))
                        .tabBarPresent(false)

                case .promotionDetail(let clubId):
                    PromotionDetailView(clubId: clubId)

                case .notification:
                    NotificationView(onBack: { path.removeLast() })
                        .tabBarPresent(false)

                case .search:
                    EmptyView()
                }
            }

            if showSearch {
                SearchView(isPresented: $showSearch, onSelectClub: { clubId in
                    showSearch = false
                    path.append(HomeRoute.promotionDetail(clubId))
                })
                .tabBarPresent(false)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSearch)
    }
}
