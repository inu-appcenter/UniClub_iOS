//
//  QnADetailViewModel.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation
import Combine

enum QnABlockTarget: Equatable {
    case question(id: Int)
    case answer(id: Int)

    var dialogTitle: String {
        switch self {
        case .question:
            return "이 질문 작성자를 차단하시겠습니까?"
        case .answer:
            return "이 답변 작성자를 차단하시겠습니까?"
        }
    }
}

@MainActor
final class QnADetailViewModel: ObservableObject {
    let questionId: Int

    @Published private(set) var detail: QnAQuestionDetail?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSubmittingAnswer: Bool = false
    @Published private(set) var isSubmittingReport: Bool = false
    @Published private(set) var isSubmittingBlock: Bool = false
    @Published var errorMessage: String?

    @Published var answerText: String = ""

    @Published var showReportDialog: Bool = false
    @Published var reportReason: String = ""
    @Published private(set) var selectedReportTarget: QnAReportTarget?

    @Published var showBlockDialog: Bool = false
    @Published private(set) var selectedBlockTarget: QnABlockTarget?

    init(questionId: Int) {
        self.questionId = questionId
    }

    var isSubmitEnabled: Bool {
        !answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmittingAnswer
    }

    var isReportSubmitEnabled: Bool {
        !reportReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmittingReport
    }

    func loadDetail() async {
        isLoading = true
        defer { isLoading = false }

        do {
            detail = try await QnAService.fetchQuestionDetail(questionId: questionId)
            errorMessage = nil
        } catch {
            errorMessage = "질문 상세를 불러오지 못했습니다."
        }
    }

    func submitAnswer(parentAnswerId: Int? = nil) async -> Bool {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        isSubmittingAnswer = true
        defer { isSubmittingAnswer = false }

        do {
            _ = try await QnAService.createAnswer(
                questionId: questionId,
                content: trimmed,
                anonymous: false,
                parentAnswerId: parentAnswerId
            )
            answerText = ""
            await loadDetail()
            return true
        } catch {
            errorMessage = "답변을 등록하지 못했습니다."
            return false
        }
    }

    func deleteQuestion() async -> Bool {
        do {
            try await QnAService.deleteQuestion(questionId: questionId)
            return true
        } catch {
            errorMessage = "질문을 삭제하지 못했습니다."
            return false
        }
    }

    func deleteAnswer(answerId: Int) async {
        do {
            try await QnAService.deleteAnswer(answerId: answerId)
            await loadDetail()
        } catch {
            errorMessage = "답변을 삭제하지 못했습니다."
        }
    }

    func markAnswered() async {
        do {
            try await QnAService.markQuestionAnswered(questionId: questionId)
            await loadDetail()
        } catch {
            errorMessage = "답변 완료 처리에 실패했습니다."
        }
    }

    func presentReportDialog(target: QnAReportTarget) {
        selectedReportTarget = target
        reportReason = ""
        showReportDialog = true
    }

    func dismissReportDialog() {
        showReportDialog = false
        reportReason = ""
        selectedReportTarget = nil
    }

    func submitReport() async -> Bool {
        guard let selectedReportTarget else { return false }

        let trimmedReason = reportReason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReason.isEmpty else { return false }

        isSubmittingReport = true
        defer { isSubmittingReport = false }

        do {
            try await QnAService.report(target: selectedReportTarget, reason: trimmedReason)
            dismissReportDialog()
            return true
        } catch {
            errorMessage = "신고를 접수하지 못했습니다."
            return false
        }
    }

    func presentBlockDialog(target: QnABlockTarget) {
        selectedBlockTarget = target
        showBlockDialog = true
    }

    func dismissBlockDialog() {
        showBlockDialog = false
        selectedBlockTarget = nil
    }

    func submitBlock() async -> Bool {
        guard let selectedBlockTarget, !isSubmittingBlock else { return false }

        isSubmittingBlock = true
        defer { isSubmittingBlock = false }

        do {
            switch selectedBlockTarget {
            case .question(let questionId):
                try await QnAService.blockQuestionAuthor(questionId: questionId)
            case .answer(let answerId):
                try await QnAService.blockAnswerAuthor(answerId: answerId)
            }

            dismissBlockDialog()
            await loadDetail()
            return true
        } catch {
            errorMessage = "차단을 완료하지 못했습니다."
            return false
        }
    }

    var reportDialogTitle: String {
        selectedReportTarget?.dialogTitle ?? "신고하시겠습니까?"
    }

    var blockDialogTitle: String {
        selectedBlockTarget?.dialogTitle ?? "이 사용자를 차단하시겠습니까?"
    }

    var topLevelAnswers: [QnAAnswerItem] {
        guard let detail else { return [] }
        return detail.answers.filter { $0.parentAnswerId == nil }
    }

    func replies(for answerId: Int) -> [QnAAnswerItem] {
        guard let detail else { return [] }
        return detail.answers.filter { $0.parentAnswerId == answerId }
    }
}
