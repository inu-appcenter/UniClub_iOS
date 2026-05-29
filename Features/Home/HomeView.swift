//
//  HomeView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    // MARK: Dependencies
    @Environment(\.appMetrics) private var m
    @Environment(\.tabBarHeight) private var tabBarHeight

    // MARK: Routing Callbacks
    let onTapAll: () -> Void
    let onTapCategory: (String) -> Void
    let onTapSearch: () -> Void
    let onTapClub: (Int) -> Void
    let onTapNotification: () -> Void

    // MARK: Constants (Coordinate Spaces)
    private let mainClubsScrollSpace = "home.mainClubs.scroll"

    // MARK: State - Main Clubs (추천 동아리)
    @State private var mainClubs: [MainClubItem] = []
    @State private var mainClubsError: String?

    /// 즐겨찾기 토글 중인 clubId 집합
    @State private var favoriteLoadingClubIDs: Set<Int> = []

    /// “끝에서 더 당겼을 때만” 추가 로드를 위한 트리거 진행도(0~1)
    @State private var refreshTriggerProgress: CGFloat = 0
    /// 한 번의 pull 동안 1회만 발동시키기 위한 락
    @State private var didFireRefreshOnThisPull: Bool = false
    /// 추가 로딩 중 UI 상태
    @State private var isLoadingMoreClubs: Bool = false
    /// 더 불러올 동아리가 없을 때 true
    @State private var allClubsLoaded: Bool = false

    /// 최초 로드 1회 보장
    @State private var didLoadOnce: Bool = false

    @State private var hasUnreadNotification: Bool = false

    // MARK: Body

    var body: some View {
        ScreenContainer(scroll: false, bottomPadding: .none) { _ in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    header
                        .padding(.top, m.space14)

                    bannerCarousel
                        .padding(.top, m.space28)

                    recommendedSection
                        .padding(.top, m.space24 - m.space2)

                    divider
                        .padding(.top, m.space18)

                    categoryRow
                        .padding(.top, m.space24 - m.space2)

                }
                .padding(.bottom, tabBarHeight)
            }
        }
        .task { await initialLoadIfNeeded() }
        .task { await loadUnreadNotificationStatus() }
    }

    // MARK: - Header

    private var header: some View {
        let iconGap = m.space18 + m.space4

        return HStack(alignment: .center, spacing: 0) {
            Image("logo_uniclub")
                .resizable()
                .scaledToFit()
                .frame(height: m.space24)

            Spacer(minLength: 0)

            Button(action: onTapSearch) {
                Image("icon_search")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: m.space24, height: m.space24)
            }
            .buttonStyle(.plain)

            Spacer().frame(width: iconGap)

            Button(action: onTapNotification) {
                ZStack(alignment: .topTrailing) {
                    Image("icon_alarm")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: m.space20, height: m.space20)

                    if hasUnreadNotification {
                        Circle()
                            .fill(AppColors.brand)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Banner

    private var bannerCarousel: some View {
        BannerCarouselView()
    }

    // MARK: - Recommended (Main Clubs)

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: m.space12) {
            Text("이런 동아리는 어떠세요?")
                .font(AppTypography.subtitleStrong())
                .foregroundStyle(AppColors.textPrimary)

            if let mainClubsError {
                Text(mainClubsError)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: m.space12) {

                    ForEach(mainClubs) { club in
                        MainClubCardView(
                            club: club,
                            cardWidth: recommendedCardWidth(),
                            cardHeight: recommendedCardHeight(),
                            isFavoriteLoading: favoriteLoadingClubIDs.contains(club.id),
                            onTap: { onTapClub(club.id) },
                            onFavoriteTap: {
                                Task { await handleFavoriteTap(clubId: club.id) }
                            }
                        )
                        .id(club.id)
                    }

                    if !allClubsLoaded {
                        refreshTriggerCard(
                            width: recommendedCardWidth() / 2,
                            height: recommendedCardHeight()
                        )
                        .background(refreshTriggerProgressReader)
                    }
                }
                .padding(.vertical, m.space4)
            }
            .coordinateSpace(name: mainClubsScrollSpace)
            .onPreferenceChange(RefreshTriggerProgressKey.self) { progress in
                refreshTriggerProgress = progress
                handleRefreshTrigger(progress: progress)
            }
        }
        .onDisappear {
            didLoadOnce = false
            mainClubs = []
            isLoadingMoreClubs = false
            didFireRefreshOnThisPull = false
            allClubsLoaded = false
        }
    }

    private var refreshTriggerProgressReader: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .named(mainClubsScrollSpace))
            let w = max(1, frame.width)

            let maxW = min(m.screenSize.width, m.contentMaxWidth)
            let visibleMaxX = maxW - (m.horizontalPadding * 2)
            let visible = max(0, min(w, visibleMaxX - frame.minX))
            let progress = min(1, visible / w)

            Color.clear
                .preference(key: RefreshTriggerProgressKey.self, value: progress)
        }
    }

    private func handleRefreshTrigger(progress: CGFloat) {
        let threshold: CGFloat = 0.7

        if !isLoadingMoreClubs,
           !didFireRefreshOnThisPull,
           !allClubsLoaded,
           progress >= threshold {

            didFireRefreshOnThisPull = true
            Task { await appendMainClubs() }
        }

        if progress < 0.05, didFireRefreshOnThisPull {
            didFireRefreshOnThisPull = false
        }
    }

    private func refreshTriggerCard(width: CGFloat, height: CGFloat) -> some View {
        ProgressView()
            .frame(width: width, height: height)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(AppColors.textSecondary.opacity(0.25))
            .frame(height: m.hairline)
    }

    // MARK: - Category

    private var categoryRow: some View {
        VStack(alignment: .leading, spacing: m.space12) {

            HStack {
                Text("카테고리")
                    .font(AppTypography.subtitleStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)

                Button(action: onTapAll) {
                    Text("전체보기")
                        .font(AppTypography.notoSans(10, weight: .medium))
                        .foregroundStyle(Color(hex: 0xB0B0B0))
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), alignment: .center),
                    GridItem(.flexible(), alignment: .center),
                    GridItem(.flexible(), alignment: .center)
                ],
                alignment: .center,
                spacing: m.space8
            ) {
                ForEach(categoryItems, id: \.title) { item in
                    Button {
                        onTapCategory(item.title)
                    } label: {
                        VStack(spacing: m.space8) {
                            ZStack(alignment: .bottom) {
                                Color.clear.frame(height: 53 * m.scale)
                                Image(item.assetName)
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: item.w * m.scale, height: item.h * m.scale)
                            }

                            Text(item.title)
                                .font(AppTypography.notoSans(11, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, m.space8)
        }
    }

    private var categoryItems: [(title: String, assetName: String, w: CGFloat, h: CGFloat)] {
        [
            ("교양학술", "icon_category_academic",  45, 40),
            ("취미전시", "icon_category_hobby",     47, 37),
            ("체육",     "icon_category_sports",    53, 53),
            ("종교",     "icon_category_religion",  50, 50),
            ("봉사",     "icon_category_volunteer", 46, 46),
            ("문화",     "icon_category_culture",   50, 50)
        ]
    }

    // MARK: - Sizing Helpers

    private func recommendedCardWidth() -> CGFloat {
        let maxW = min(m.screenSize.width, m.contentMaxWidth)
        let contentW = maxW - (m.horizontalPadding * 2)
        return contentW * (136.0 / 324.0)
    }

    private func recommendedCardHeight() -> CGFloat {
        recommendedCardWidth() * (206.0 / 136.0)
    }

    // MARK: - Data Loading

    @MainActor
    private func loadUnreadNotificationStatus() async {
        guard let items = try? await NotificationService.fetchAll() else { return }
        hasUnreadNotification = items.contains { !$0.isRead }
    }

    @MainActor
    private func initialLoadIfNeeded() async {
        guard !didLoadOnce else { return }
        didLoadOnce = true
        await loadMainClubsInitial()
    }

    @MainActor
    private func loadMainClubsInitial() async {
        do {
            let result = try await MainClubsService.fetchMainClubs()
            var seen = Set<Int>()
            let unique = result.filter { seen.insert($0.clubId).inserted }
            self.mainClubs = Array(unique.shuffled().prefix(5))
            self.mainClubsError = nil
        } catch {
            self.mainClubs = []
            self.mainClubsError = "추천 동아리를 불러오지 못했습니다."
        }
    }

    @MainActor
    private func appendMainClubs() async {
        guard !isLoadingMoreClubs, !allClubsLoaded else { return }

        let start = Date()
        isLoadingMoreClubs = true
        defer { isLoadingMoreClubs = false }

        do {
            let result = try await MainClubsService.fetchMainClubs()

            var seen = Set<Int>()
            let unique = result.filter { seen.insert($0.clubId).inserted }

            let existingIds = Set(mainClubs.map { $0.clubId })
            let available = unique.filter { !existingIds.contains($0.clubId) }
            let newClubs = Array(available.shuffled().prefix(5))

            let elapsed = Date().timeIntervalSince(start)
            if elapsed < 1.0 {
                let ns = UInt64((1.0 - elapsed) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: ns)
            }

            if newClubs.isEmpty {
                allClubsLoaded = true
            } else {
                self.mainClubs.append(contentsOf: newClubs)
                if available.count <= newClubs.count {
                    allClubsLoaded = true
                }
            }
            self.mainClubsError = nil
        } catch {
            self.mainClubsError = "동아리를 더 불러오지 못했습니다."
        }
    }

    @MainActor
    private func handleFavoriteTap(clubId: Int) async {
        guard !favoriteLoadingClubIDs.contains(clubId) else { return }

        favoriteLoadingClubIDs.insert(clubId)
        defer { favoriteLoadingClubIDs.remove(clubId) }

        do {
            _ = try await MainClubsService.toggleFavorite(clubId: clubId)

            if let index = mainClubs.firstIndex(where: { $0.clubId == clubId }) {
                mainClubs[index] = mainClubs[index].toggledFavorite()
            }

            mainClubsError = nil
        } catch {
            mainClubsError = "관심 동아리 처리에 실패했습니다."
        }
    }

}

// MARK: - MainClubCardView (추천 카드)

// MARK: - Refresh Trigger PreferenceKey

private struct RefreshTriggerProgressKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#Preview("HomeView") {
    HomeView(
        onTapAll: {},
        onTapCategory: { _ in },
        onTapSearch: {},
        onTapClub: { _ in },
        onTapNotification: {}
    )
}
