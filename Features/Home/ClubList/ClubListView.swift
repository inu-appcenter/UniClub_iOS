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
    let mode: ClubListMode
    let onTapSearch: () -> Void

    @StateObject private var vm = ClubListViewModel()

    @State private var sort: SortOption = .default
    @State private var showSortDropdown = false

    // ✅ 페이징 중복 트리거 방지 (같은 마지막 id로는 1회만)
    @State private var lastPagingTriggeredItemId: Int? = nil

    var body: some View {
        // ✅ 커스텀 헤더를 화면 내부에 두기 때문에 topPadding을 제거한다.
        ScreenContainer(scroll: true, topPadding: .none) { m in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {

                    ClubListHeader(
                        title: mode.title,
                        onTapBack: { dismiss() },
                        onTapSearch: { onTapSearch() }
                    )
                    .padding(.bottom, m.space12)

                    // ✅ 상태 분기 (로딩/에러/빈/정상)
                    content(m)

                    Spacer(minLength: m.space24)
                }

                // Dropdown 열렸을 때 외부 탭으로 닫기
                if showSortDropdown {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showSortDropdown = false
                            }
                        }
                }

                // Floating sort pill + dropdown
                VStack(alignment: .trailing, spacing: 4) {
                    // Sort pill button
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showSortDropdown.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sort.rawValue)
                                .font(AppTypography.notoSans(10, weight: .medium))
                                .foregroundStyle(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.white)
                                .rotationEffect(.degrees(showSortDropdown ? 180 : 0))
                        }
                        .frame(width: 70, height: 25)
                        .background(Color(hex: 0x3C3C3C))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    // Dropdown options
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
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
                    }
                }
                .padding(.trailing, m.horizontalPadding)
                .padding(.top, m.space8)
            }
        }
        // ✅ 시스템 네비바는 숨기고(Back 중복 방지) 커스텀 헤더만 사용
        .navigationBarBackButtonHidden(true)
        .modifier(NavigationBarHiddenIfAvailable())
        .onChange(of: sort) { newValue in
            vm.configure(categoryQuery: mode.categoryQuery, sortBy: newValue.serverSortBy)
            lastPagingTriggeredItemId = nil
            Task { await vm.refresh() }
        }
        // ✅ 최초 진입 시 로딩
        .task {
            vm.configure(categoryQuery: mode.categoryQuery, sortBy: sort.serverSortBy)
            lastPagingTriggeredItemId = nil
            await vm.initialLoadIfNeeded()
        }
    }

    // MARK: - Content (State-driven)

    @ViewBuilder
    private func content(_ m: AppMetrics) -> some View {
        if vm.state.isLoading && vm.state.items.isEmpty {
            // 첫 로딩
            VStack(spacing: m.space12) {
                ProgressView()
                Text("불러오는 중…")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, m.space24)

        } else if let msg = vm.state.errorMessage, vm.state.items.isEmpty {
            // 첫 로딩 실패
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
            // 데이터 없음
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

        } else {
            // 정상 리스트 + 무한스크롤
            LazyVStack(spacing: m.space12) {
                ForEach(vm.state.items) { item in
                    ClubListCard(
                        item: dto(from: item),
                        onFavoriteTap: {
                            Task { await handleFavoriteTap(itemId: item.id) }
                        }
                    )
                        .onAppear {
                            // ✅ 마지막 아이템이 나타났을 때만 페이징 트리거
                            guard vm.state.items.last?.id == item.id else { return }

                            // ✅ 같은 id로는 한 번만 트리거
                            guard lastPagingTriggeredItemId != item.id else { return }
                            lastPagingTriggeredItemId = item.id

                            Task { await vm.loadMoreIfNeeded(currentItemId: item.id) }
                        }
                }

                // 다음 페이지 로딩 인디케이터 (리스트 하단)
                if vm.state.isLoading && vm.state.hasNext {
                    ProgressView()
                        .padding(.vertical, m.space12)
                }

                // 페이지네이션 중 에러 표시(아이템이 있을 때도)
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
        _ = try? await MainClubsService.toggleFavorite(clubId: itemId)
        await vm.refresh()
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

/// iOS 16+: .toolbar(.hidden, for: .navigationBar)로 네비바를 숨김
/// iOS 15 이하: .navigationBarHidden(true) 사용
private struct NavigationBarHiddenIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .navigationBar)
        } else {
            content.navigationBarHidden(true)
        }
    }
}
