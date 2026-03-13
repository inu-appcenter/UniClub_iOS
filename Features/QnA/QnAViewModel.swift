//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation
import Combine

@MainActor
final class QnAViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var selectedClub: QnAClubSummary?
    @Published var answeredOnly: Bool = false
    @Published var onlyMyQuestions: Bool = false

    @Published private(set) var questions: [QnAQuestionSummary] = []
    @Published private(set) var hasNext: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private var didLoadOnce = false
    private var searchTask: Task<Void, Never>?

    func initialLoadIfNeeded() async {
        guard !didLoadOnce else { return }
        didLoadOnce = true
        await loadQuestions()
    }

    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.loadQuestions()
        }
    }

    func loadQuestions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await QnAService.searchQuestions(
                keyword: keyword,
                clubId: selectedClub?.clubId,
                answered: answeredOnly,
                onlyMyQuestions: onlyMyQuestions,
                size: 10
            )

            questions = response.content
            hasNext = response.hasNext
            errorMessage = nil
        } catch {
            questions = []
            hasNext = false
            errorMessage = "질문 목록을 불러오지 못했습니다."
        }
    }

    func toggleAnsweredOnly() {
        answeredOnly.toggle()
        scheduleSearch()
    }

    func toggleOnlyMyQuestions() {
        onlyMyQuestions.toggle()
        scheduleSearch()
    }

    func selectClub(_ club: QnAClubSummary?) {
        selectedClub = club
        scheduleSearch()
    }

    func clearClub() {
        selectedClub = nil
        scheduleSearch()
    }
}
