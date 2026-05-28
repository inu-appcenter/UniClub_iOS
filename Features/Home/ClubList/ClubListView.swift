//
//  ClubListView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case favorite = "즐겨찾기"
    case active   = "모집중"
    case `default` = "기본"

    var id: String { rawValue }

    // TODO(backend): sortBy 허용값 확정되면 아래 매핑을 업데이트.
    var serverSortBy: String {
        switch self {
        case .favorite: return "name"
        case .active:   return "name"
        case .default:  return "name"
        }
    }
}

/// Home_Tap_전체보기 / Home_Tap_문화분과 → 둘 다 이 화면 하나로 커버
struct ClubListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m
    let mode: ClubListMode

    @StateObject private var vm = ClubListViewModel()

    @State private var sort: SortOption = .default
    @State private var showSortDropdown = false
    @State private var showSearch = false

    @State private var lastPagingTriggeredItemId: Int? = nil
    @State private var selectedClubId: Int? = nil

    private var filteredItems: [ClubListViewModel.Item] {
        switch sort {
        case .favorite: return vm.state.items.filter { $0.favorite }
        case .active:   return vm.state.items.filter { $0.status == "ACTIVE" }
        case .default:  return vm.state.items
        }
    }

    var body: some View {
        ZStack {
            // ── 스크롤 가능한 본문 ──────────────────────────────
            ScreenContainer(scroll: true, topPadding: .none) { _ in
                VStack(alignment: .leading, spacing: 0) {
                    ClubListHeader(
                        title: mode.title,
                        onTapBack: { dismiss() },
                        onTapSearch: { withAnimation(.easeInOut(duration: 0.25)) { showSearch = true } }
                    )
                    .padding(.bottom, m.space12)

                    // ── 정렬 버튼 (콘텐츠와 함께 스크롤) ──────────
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    showSortDropdown.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(sort.rawValue)
                                        .font(AppTypography.notoSans(11, weight: .medium))
                                        .foregroundStyle(.white)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundStyle(.white)
                                        .rotationEffect(.degrees(showSortDropdown ? 180 : 0))
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 25)
                                .background(Color(hex: 0x3C3C3C))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            if showSortDropdown {
                                VStack(spacing: 0) {
                                    ForEach(SortOption.allCases) { option in
                                        Button {
                                            sort = option
                                            withAnimation { showSortDropdown = false }
                                        } label: {
                                            HStack {
                                                Text(option.rawValue)
                                                    .font(AppTypography.notoSans(10, weight: .medium))
                                                    .foregroundStyle(.white)
                                                Spacer(minLength: 0)
                                                if sort == option {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 9, weight: .bold))
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .frame(height: 32)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .frame(width: 100)
                                .background(Color(hex: 0x3C3C3C))
                                .clipShape(RoundedRectangle(cornerRadius: m.radius10))
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
                            }
                        }
                    }
                    .padding(.bottom, m.space8)

                    content(m)

                    Spacer(minLength: m.space24)
                }
            }
            .navigationBarBackButtonHidden(true)
            .modifier(NavigationBarHiddenIfAvailable())
            .onChange(of: sort) { newValue in
                vm.configure(categoryQuery: mode.categoryQuery, sortBy: newValue.serverSortBy)
                lastPagingTriggeredItemId = nil
                Task { await vm.refresh() }
            }
            .task {
                vm.configure(categoryQuery: mode.categoryQuery, sortBy: sort.serverSortBy)
                lastPagingTriggeredItemId = nil
                await vm.initialLoadIfNeeded()
            }
            .navigationDestination(item: $selectedClubId) { clubId in
                PromotionDetailView(clubId: clubId)
            }

            // ── 드롭다운 열렸을 때 외부 탭으로 닫기 ────────────
            if showSortDropdown {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showSortDropdown = false
                        }
                    }
            }

            // ── 검색 오버레이 ───────────────────────────────────
            if showSearch {
                SearchView(isPresented: $showSearch, onSelectClub: { clubId in
                    showSearch = false
                    selectedClubId = clubId
                })
                .tabBarPresent(false)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSearch)
    }

    // MARK: - Content (State-driven)

    @ViewBuilder
    private func content(_ m: AppMetrics) -> some View {
        if vm.state.isLoading && vm.state.items.isEmpty {
            VStack(spacing: m.space12) {
                ProgressView()
                Text("불러오는 중…")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, m.space24)

        } else if let msg = vm.state.errorMessage, vm.state.items.isEmpty {
            VStack(spacing: m.space12) {
                Text("오류가 발생했습니다")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Text(msg)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await vm.refresh() }
                } label: {
                    Text("다시 시도")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, m.space16)
                        .padding(.vertical, m.space12)
                        .background(AppColors.cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, m.space24)

        } else if vm.state.items.isEmpty {
            VStack(spacing: m.space12) {
                Text("표시할 동아리가 없어요")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Text("조건을 바꾸거나 다시 시도해보세요.")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, m.space24)

        } else if filteredItems.isEmpty {
            VStack(spacing: m.space12) {
                Text("해당하는 동아리가 없어요")
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Text("다른 정렬 조건을 선택해보세요.")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, m.space24)

        } else {
            LazyVStack(spacing: m.space16) {
                ForEach(filteredItems) { item in
                    Button {
                        selectedClubId = item.id
                    } label: {
                        ClubListCard(
                            item: dto(from: item),
                            onFavoriteTap: {
                                Task { await handleFavoriteTap(itemId: item.id) }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        guard filteredItems.last?.id == item.id else { return }
                        guard lastPagingTriggeredItemId != item.id else { return }
                        lastPagingTriggeredItemId = item.id
                        Task { await vm.loadMoreIfNeeded(currentItemId: item.id) }
                    }
                }

                if vm.state.isLoading && vm.state.hasNext {
                    ProgressView()
                        .padding(.vertical, m.space12)
                }

                if let msg = vm.state.errorMessage, !vm.state.items.isEmpty {
                    Text(msg)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.vertical, m.space12)
                }
            }
        }
    }

    // MARK: - Favorite

    @MainActor
    private func handleFavoriteTap(itemId: Int) async {
        vm.toggleFavoriteLocally(itemId: itemId)
        _ = try? await MainClubsService.toggleFavorite(clubId: itemId)
    }

    // MARK: - Adapter

    private func dto(from item: ClubListViewModel.Item) -> ClubsService.ClubDTO {
        .init(
            id: item.id,
            name: item.name,
            info: item.info,
            status: item.status,
            favorite: item.favorite,
            category: item.category,
            clubProfileUrl: item.imageURL?.absoluteString
        )
    }
}

private struct NavigationBarHiddenIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .navigationBar)
        } else {
            content.navigationBarHidden(true)
        }
    }
}
