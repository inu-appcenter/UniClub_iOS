//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import SwiftUI

struct QnAClubPickerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appMetrics) private var m

    let initiallySelectedClub: QnAClubSummary?
    let onSelect: (QnAClubSummary) -> Void

    @State private var keyword: String = ""
    @State private var clubs: [QnAClubSummary] = []
    @State private var selectedClub: QnAClubSummary?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        ScreenContainer(
            scroll: false,
            background: AppColors.backgroundSecondary,
            topPadding: .none,
            bottomPadding: .custom(m.space16)
        ) { _ in
            VStack(alignment: .leading, spacing: m.space16) {
                header

                QnASearchBar(
                    placeholder: "질문할 동아리를 검색하세요.",
                    text: $keyword,
                    onSubmit: {
                        Task { await searchClubs() }
                    }
                )
                .onChange(of: keyword) { _ in
                    scheduleSearch()
                }

                Group {
                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if let errorMessage {
                        VStack {
                            Spacer()
                            Text(errorMessage)
                                .font(AppTypography.body())
                                .foregroundStyle(AppColors.textSecondary)
                            Spacer()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: m.space18) {
                                ForEach(clubs) { club in
                                    Button {
                                        selectedClub = club
                                    } label: {
                                        VStack(alignment: .leading, spacing: m.space2) {
                                            Text(club.clubName)
                                                .font(AppTypography.bodyStrong())
                                                .foregroundStyle(
                                                    selectedClub?.clubId == club.clubId
                                                    ? AppColors.brand
                                                    : AppColors.textPrimary
                                                )

                                            Text(club.categoryDisplayName)
                                                .font(AppTypography.caption())
                                                .foregroundStyle(
                                                    selectedClub?.clubId == club.clubId
                                                    ? AppColors.brand
                                                    : AppColors.textSecondary
                                                )
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, m.space8)
                        }
                    }
                }

                Button {
                    guard let selectedClub else { return }
                    onSelect(selectedClub)
                    dismiss()
                } label: {
                    Text("선택")
                        .font(AppTypography.bodyStrong())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: m.controlHeight48)
                        .background(AppColors.brand.opacity(selectedClub == nil ? 0.35 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: m.radiusPill))
                }
                .disabled(selectedClub == nil)
                .buttonStyle(.plain)
            }
        }
        .task {
            selectedClub = initiallySelectedClub
            await searchClubs()
        }
    }

    private var header: some View {
        ZStack {
            Text("동아리 선택")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                Color.clear
                    .frame(width: m.controlHeight44, height: m.controlHeight44)

                Spacer(minLength: 0)

                Button("취소") {
                    dismiss()
                }
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: m.controlHeight44, height: m.controlHeight44)
            }
        }
        .padding(.top, m.space18)
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            await searchClubs()
        }
    }

    @MainActor
    private func searchClubs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            clubs = try await QnAClubService.searchClubs(keyword: keyword)
            errorMessage = nil
        } catch {
            clubs = []
            errorMessage = "동아리 목록을 불러오지 못했습니다."
        }
    }
}
