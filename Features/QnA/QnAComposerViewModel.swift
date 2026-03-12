//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Combine
import Foundation

@MainActor
final class QnAComposerViewModel: ObservableObject {
    @Published var selectedClub: QnAClubSummary?
    @Published var content: String
    @Published var isAnonymous: Bool = false
    @Published private(set) var isSubmitting: Bool = false
    @Published var errorMessage: String?

    let questionId: Int?

    init(
        questionId: Int? = nil,
        selectedClub: QnAClubSummary? = nil,
        initialContent: String = ""
    ) {
        self.questionId = questionId
        self.selectedClub = selectedClub
        self.content = initialContent
    }

    var isEditMode: Bool {
        questionId != nil
    }

    var isSubmitEnabled: Bool {
        let hasContent = !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isEditMode {
            return hasContent && !isSubmitting
        }
        return selectedClub != nil && hasContent && !isSubmitting
    }

    func toggleAnonymous() {
        isAnonymous.toggle()
    }

    func submit() async -> Bool {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            if let questionId {
                try await QnAService.updateQuestion(
                    questionId: questionId,
                    content: trimmedContent
                )
            } else {
                guard let clubId = selectedClub?.clubId else {
                    errorMessage = "동아리를 선택해주세요."
                    return false
                }

                _ = try await QnAService.createQuestion(
                    clubId: clubId,
                    content: trimmedContent,
                    anonymous: isAnonymous
                )
            }

            errorMessage = nil
            return true
        } catch {
            errorMessage = isEditMode ? "질문을 수정하지 못했습니다." : "질문을 등록하지 못했습니다."
            return false
        }
    }
}
