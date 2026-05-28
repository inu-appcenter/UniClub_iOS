//
//  ClubListViewModel.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import Foundation
import Combine

@MainActor
final class ClubListViewModel: ObservableObject {

    struct Item: Identifiable {
        let id: Int
        let name: String
        let info: String
        let status: String
        let favorite: Bool
        let category: String
        let imageURL: URL?
    }

    struct State {
        var items: [Item] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var hasNext: Bool = true

        // Query
        var categoryQuery: String? = nil
        var sortBy: String = "name"           // ✅ 서버 확정값(기본)
        var cursorName: String? = nil
        var size: Int = 10
    }

    @Published private(set) var state = State()
    private var didInitialLoad = false

    func initialLoadIfNeeded() async {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        await refresh()
    }
    
    /// ✅ 단일 configure만 유지 (중복/꼬임 방지)
    /// - sortBy는 서버 계약 확정 전까지 "name"만 허용(400 방지)
    func configure(categoryQuery: String?, sortBy: String? = nil) {
        state.categoryQuery = categoryQuery

        if let sortBy, sortBy == "name" {
            state.sortBy = "name"
        } else {
            // 서버 허용값 확정 전: 안전하게 name으로 고정
            state.sortBy = "name"
        }
    }

    func toggleFavoriteLocally(itemId: Int) {
        guard let idx = state.items.firstIndex(where: { $0.id == itemId }) else { return }
        let old = state.items[idx]
        state.items[idx] = Item(
            id: old.id,
            name: old.name,
            info: old.info,
            status: old.status,
            favorite: !old.favorite,
            category: old.category,
            imageURL: old.imageURL
        )
    }

    func refresh() async {
        state.items = []
        state.cursorName = nil
        state.hasNext = true
        state.errorMessage = nil
        await loadMore(force: true)
    }

    /// 무한 스크롤 트리거: 현재 표시 중인 item이 마지막이면 다음 페이지 호출
    func loadMoreIfNeeded(currentItemId: Int) async {
        guard let last = state.items.last else { return }
        guard last.id == currentItemId else { return }
        await loadMore(force: false)
    }

    private func loadMore(force: Bool) async {
        guard !state.isLoading else { return }
        guard state.hasNext || force else { return }

        state.isLoading = true
        state.errorMessage = nil

        do {
            let res = try await ClubsService.fetchClubs(
                category: state.categoryQuery,
                sortBy: state.sortBy,          // "name" 고정
                cursorName: state.cursorName,
                size: state.size
            )

            let mapped: [Item] = res.content.map {
                Item(
                    id: $0.id,
                    name: $0.name,
                    info: $0.info ?? "",                 // ✅ 기본값 처리
                    status: $0.status ?? "SCHEDULED",    // ✅ 임시 기본값(원하면 "")
                    favorite: $0.favorite,
                    category: $0.category,
                    imageURL: $0.imageURL
                )
            }

            state.items.append(contentsOf: mapped)
            state.hasNext = res.hasNext

            // cursorName은 서버 설명대로 "name" 기반 커서
            state.cursorName = state.items.last?.name

        } catch {
            state.errorMessage = error.localizedDescription
        }

        state.isLoading = false
    }
}
