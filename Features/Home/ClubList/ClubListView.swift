//
//  ClubListView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    /// UI 표시용
    case `default` = "기본"
    case recent = "최신순"
    case popular = "인기순"

    var id: String { rawValue }

    /// ✅ 서버 sortBy로 변환 (API 계약 확정 전까지는 안전하게 name으로 고정)
    /// - NOTE: Swagger 상 default value가 name이고, 유효하지 않으면 400(INVALID_SORT_CONDITION).
    /// - TODO(backend): sortBy 허용값 확정되면 아래 매핑을 업데이트.
    var serverSortBy: String {
        switch self {
        case .default:
            return "name"
        case .recent:
            // TODO: 예) "createdAt" 또는 "recent"
            return "name"
        case .popular:
            // TODO: 예) "popular" 또는 "views"
            return "name"
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
    @State private var showSortSheet = false

    // ✅ 페이징 중복 트리거 방지 (같은 마지막 id로는 1회만)
    @State private var lastPagingTriggeredItemId: Int? = nil

    var body: some View {
        // ✅ 커스텀 헤더를 화면 내부에 두기 때문에 topPadding을 제거한다.
        ScreenContainer(scroll: true, topPadding: .none) { m in
            VStack(alignment: .leading, spacing: 0) {

                ClubListHeader(
                    title: mode.title,
                    onTapBack: { dismiss() },
                    onTapSearch: { onTapSearch() }
                )
                .padding(.bottom, m.space12)

                // 정렬 버튼 (UI는 keep)
                ClubListSortButton(selected: sort) {
                    showSortSheet = true
                }
                .padding(.bottom, m.space12)

                // ✅ 상태 분기 (로딩/에러/빈/정상)
                content(m)

                Spacer(minLength: m.space24)
            }
        }
        // ✅ 시스템 네비바는 숨기고(Back 중복 방지) 커스텀 헤더만 사용
        .navigationBarBackButtonHidden(true)
        .modifier(NavigationBarHiddenIfAvailable())
        .sheet(isPresented: $showSortSheet) {
            SortSheet(selected: $sort)
                .modifier(SortSheetDetent(height: 260))
        }
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
                    ClubListCard(item: dto(from: item))
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

/// .presentationDetents는 iOS 16+ API
private struct SortSheetDetent: ViewModifier {
    let height: CGFloat
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.height(height)])
        } else {
            content
        }
    }
}
