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

    /// “끝에서 더 당겼을 때만” 새로고침을 위한 트리거 진행도(0~1)
    @State private var refreshTriggerProgress: CGFloat = 0
    /// 한 번의 pull 동안 1회만 발동시키기 위한 락
    @State private var didFireRefreshOnThisPull: Bool = false
    /// 새로고침 중 UI 상태
    @State private var isRefreshingMainClubs: Bool = false

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
                        .padding(.top, m.space12)

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
                        .frame(width: m.space24, height: m.space24)

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

            ScrollViewReader { proxy in
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

                        refreshTriggerCard(
                            width: recommendedCardWidth(),
                            height: recommendedCardHeight()
                        )
                        .background(refreshTriggerProgressReader)
                    }
                    .padding(.vertical, m.space4)
                }
                .coordinateSpace(name: mainClubsScrollSpace)
                .onPreferenceChange(RefreshTriggerProgressKey.self) { progress in
                    refreshTriggerProgress = progress
                    handleRefreshTrigger(progress: progress, proxy: proxy)
                }
            }
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

    private func handleRefreshTrigger(progress: CGFloat, proxy: ScrollViewProxy) {
        let threshold: CGFloat = 0.7

        if !isRefreshingMainClubs,
           !didFireRefreshOnThisPull,
           progress >= threshold {

            didFireRefreshOnThisPull = true
            Task { await refreshMainClubsAndScrollToFirst(proxy: proxy) }
        }

        if progress < 0.05, didFireRefreshOnThisPull {
            didFireRefreshOnThisPull = false
        }
    }

    private func refreshTriggerCard(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: m.radius18, style: .continuous)
            .fill(AppColors.fieldFill)
            .frame(width: width, height: height)
            .overlay {
                if isRefreshingMainClubs {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(AppTypography.notoSans(m.space18, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
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
                spacing: 64
            ) {
                ForEach(categoryItems, id: \.title) { item in
                    Button {
                        onTapCategory(item.title)
                    } label: {
                        VStack(spacing: m.space8) {
                            Image(item.assetName)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: m.space32 + m.space12, height: m.space32 + m.space12)

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

    private var categoryItems: [(title: String, assetName: String)] {
        [
            ("교양학술", "icon_category_academic"),
            ("취미전시", "icon_category_hobby"),
            ("체육",     "icon_category_sports"),
            ("종교",     "icon_category_religion"),
            ("봉사",     "icon_category_volunteer"),
            ("문화",     "icon_category_culture")
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

            self.mainClubs = pickRandomFive(from: unique)
            self.mainClubsError = nil
        } catch {
            self.mainClubs = []
            self.mainClubsError = "추천 동아리를 불러오지 못했습니다."
        }
    }

    @MainActor
    private func refreshMainClubsAndScrollToFirst(proxy: ScrollViewProxy) async {
        guard !isRefreshingMainClubs else { return }

        let start = Date()
        isRefreshingMainClubs = true
        defer { isRefreshingMainClubs = false }

        do {
            let result = try await MainClubsService.fetchMainClubs()

            var seen = Set<Int>()
            let unique = result.filter { seen.insert($0.clubId).inserted }

            self.mainClubs = pickRandomFive(from: unique)
            self.mainClubsError = nil
        } catch {
            self.mainClubsError = "새 동아리를 불러오지 못했습니다."
        }

        let elapsed = Date().timeIntervalSince(start)
        let minDuration: TimeInterval = 1.0
        if elapsed < minDuration {
            let ns = UInt64((minDuration - elapsed) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
        }

        if let first = mainClubs.first {
            withAnimation(.easeInOut) {
                proxy.scrollTo(first.id, anchor: .leading)
            }
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

    private func pickRandomFive(from items: [MainClubItem]) -> [MainClubItem] {
        if items.count <= 5 { return items }
        return Array(items.shuffled().prefix(5))
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
