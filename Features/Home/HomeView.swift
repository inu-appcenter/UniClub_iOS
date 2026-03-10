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

    // MARK: Routing Callbacks
    let onTapAll: () -> Void
    let onTapCategory: (String) -> Void
    let onTapSearch: () -> Void

    // MARK: Constants (Coordinate Spaces)
    private let mainClubsScrollSpace = "home.mainClubs.scroll"

    // (삭제) BannerCarouselView가 자체 로딩/에러 처리

    // MARK: State - Main Clubs (추천 동아리)
    @State private var mainClubs: [MainClubItem] = []
    @State private var mainClubsError: String?

    /// “끝에서 더 당겼을 때만” 새로고침을 위한 트리거 진행도(0~1)
    @State private var refreshTriggerProgress: CGFloat = 0
    /// 한 번의 pull 동안 1회만 발동시키기 위한 락
    @State private var didFireRefreshOnThisPull: Bool = false
    /// 새로고침 중 UI 상태
    @State private var isRefreshingMainClubs: Bool = false

    /// 최초 로드 1회 보장
    @State private var didLoadOnce: Bool = false

    // MARK: Body

    var body: some View {
        ScreenContainer(scroll: false) { _ in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    header
                        .padding(.top, m.space14)

                    // ✅ 배너
                    bannerCarousel
                        .padding(.top, m.space12)

                    // ✅ “이런 동아리는 어떠세요?” (랜덤 5개 + 끝에서 추가 pull 시 새로고침)
                    recommendedSection
                        .padding(.top, m.space24 - m.space2)

                    divider
                        .padding(.top, m.space18)

                    categoryRow
                        .padding(.top, m.space24 - m.space2)

                    // ✅ 탭바(높이 89) 영역만큼 스크롤 하단 여유
                    Spacer(minLength: m.controlHeight52 + m.space32 + m.space4)
                }
            }
            .background(AppColors.background)
        }
        .task { await initialLoadIfNeeded() }
    }

    // MARK: - Header

    private var header: some View {
        let iconGap = m.space18 + m.space4 // (=22)

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

            Button(action: {
                // NOTE(기능 연동 전):
                // - 알림 화면(Notifications) 라우팅/디자인 확정 후 연결한다.
            }) {
                Image("icon_alarm")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: m.space24, height: m.space24)
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
                .font(AppTypography.bodyStrong())
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
                                cardHeight: recommendedCardHeight()
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
                        .font(.system(size: m.space18, weight: .semibold))
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
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: 0)

                Button(action: onTapAll) {
                    Text("전체보기")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
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
                spacing: m.space24
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
                                .font(AppTypography.caption())
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

    // MARK: - Sizing Helpers (Home_2.json 기준)

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

    private func pickRandomFive(from items: [MainClubItem]) -> [MainClubItem] {
        if items.count <= 5 { return items }
        return Array(items.shuffled().prefix(5))
    }
}

// MARK: - MainClubCardView (추천 카드)

private struct MainClubCardView: View {
    @Environment(\.appMetrics) private var m

    let club: MainClubItem
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            cardImage
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.15),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: m.space32 + m.space24)
            .frame(maxWidth: .infinity, alignment: .top)

            HStack(alignment: .center) {
                Text(club.name)
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: club.favorite ? "heart.fill" : "heart")
                    .font(.system(size: m.space16, weight: .semibold))
                    .foregroundStyle(club.favorite ? Color.red : Color.white)
            }
            .padding(.horizontal, m.space10)
            .padding(.top, m.space10)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: m.radius18, style: .continuous))
    }

    @ViewBuilder
    private var cardImage: some View {
        if let url = club.imageUrl {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    defaultClubImage
                case .failure:
                    defaultClubImage
                @unknown default:
                    defaultClubImage
                }
            }
        } else {
            defaultClubImage
        }
    }

    private var defaultClubImage: some View {
        Image("image_default_clubs")
            .resizable()
            .scaledToFill()
            .frame(width: cardWidth, height: cardHeight)
            .background(AppColors.fieldFill)
    }
}

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
        onTapSearch: {}
    )
}
