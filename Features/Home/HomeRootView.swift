//
//  HomeRootView.swift
//  UniClub
//

import SwiftUI

struct HomeRootView: View {
    @Binding var path: NavigationPath

    var body: some View {
        HomeView(
            onTapAll: { path.append(HomeRoute.clubListAll) },
            onTapCategory: { name in path.append(HomeRoute.clubListCategory(name)) },
            onTapSearch: { path.append(HomeRoute.search) }
        )
        .navigationDestination(for: HomeRoute.self) { route in
            switch route {
            case .clubListAll:
                ClubListView(mode: .all, onTapSearch: { path.append(HomeRoute.search) })
                    .tabBarPresent(false)

            case .clubListCategory(let name):
                ClubListView(mode: .category(name), onTapSearch: { path.append(HomeRoute.search) })
                    .tabBarPresent(false)

            case .search:
                SearchView()
                    .tabBarPresent(false)
            }
        }
    }
}
