//
//  SearchView.swift
//  UniClub
//

import SwiftUI

struct SearchView: View {
    @Binding var isPresented: Bool
    @Environment(\.appMetrics) private var m

    @State private var query: String = ""
    @State private var clubs: [ClubsService.ClubDTO] = []
    @State private var isLoading: Bool = false
    @State private var searchTask: Task<Void, Never>? = nil
    @FocusState private var searchFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // White background (frame bg is white; gray search bar is visible against it)
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                searchBarRow
                    .padding(.horizontal, m.horizontalPadding)
                    .padding(.top, m.space18)
                    .padding(.bottom, m.space20)

                sheetContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
                    .ignoresSafeArea(edges: .bottom)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32 * m.scale,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 32 * m.scale
                        )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 50, x: 0, y: 4)
            }
        }
        .tabBarPresent(false)
        .onAppear { searchFocused = true }
        .onChange(of: query) { _ in scheduleSearch() }
    }

    // MARK: - Search Bar

    private var searchBarRow: some View {
        HStack(spacing: m.space12) {
            HStack(spacing: m.space8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: 0x595959))

                TextField("동아리를 검색해보세요 :D", text: $query)
                    .font(AppTypography.notoSans(12))
                    .foregroundStyle(AppColors.textPrimary)
                    .focused($searchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(hex: 0x595959))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, m.space12)
            .frame(height: 35 * m.scale)
            .background(Color(hex: 0xD9D9D9))
            .clipShape(RoundedRectangle(cornerRadius: m.radius18, style: .continuous))

            Button("취소") { close() }
                .font(AppTypography.notoSans(14, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .buttonStyle(.plain)
        }
    }

    // MARK: - Sheet Content

    @ViewBuilder
    private var sheetContent: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else if clubs.isEmpty {
            VStack {
                Spacer()
                if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("검색 결과가 없어요")
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: m.space16) {
                    ForEach(clubs, id: \.id) { club in
                        ClubListCard(
                            item: club,
                            onFavoriteTap: {
                                Task { await handleFavoriteTap(clubId: club.id) }
                            }
                        )
                    }
                }
                .padding(.horizontal, m.horizontalPadding)
                .padding(.vertical, m.space16)
            }
        }
    }

    // MARK: - Actions

    private func close() {
        searchTask?.cancel()
        isPresented = false
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            clubs = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(keyword: q)
        }
    }

    @MainActor
    private func performSearch(keyword: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            clubs = try await SearchService.search(keyword: keyword)
        } catch {
            clubs = []
        }
    }

    @MainActor
    private func handleFavoriteTap(clubId: Int) async {
        if let idx = clubs.firstIndex(where: { $0.id == clubId }) {
            let old = clubs[idx]
            clubs[idx] = ClubsService.ClubDTO(
                id: old.id,
                name: old.name,
                info: old.info,
                status: old.status,
                favorite: !old.favorite,
                category: old.category,
                clubProfileUrl: old.clubProfileUrl
            )
        }
        _ = try? await MainClubsService.toggleFavorite(clubId: clubId)
    }
}
