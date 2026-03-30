//
//  QnAService.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation

enum QnAService {
    private static let basePath = "/api/v1/qna"
    private static let blockBasePath = "/api/v1/block"

    private struct EmptyRequestBody: Encodable {}

    static func searchQuestions(
        keyword: String,
        clubId: Int?,
        answered: Bool,
        onlyMyQuestions: Bool,
        size: Int = 10
    ) async throws -> QnAQuestionSearchResponse {
        var query: [URLQueryItem] = [
            URLQueryItem(name: "answered", value: String(answered)),
            URLQueryItem(name: "onlyMyQuestions", value: String(onlyMyQuestions)),
            URLQueryItem(name: "size", value: String(size))
        ]

        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKeyword.isEmpty {
            query.append(URLQueryItem(name: "keyword", value: trimmedKeyword))
        }

        if let clubId {
            query.append(URLQueryItem(name: "clubId", value: String(clubId)))
        }

        return try await HTTPClient.shared.get(
            "\(basePath)/search",
            query: query,
            as: QnAQuestionSearchResponse.self
        )
    }

    static func fetchQuestionDetail(questionId: Int) async throws -> QnAQuestionDetail {
        try await HTTPClient.shared.get(
            "\(basePath)/\(questionId)",
            as: QnAQuestionDetail.self
        )
    }

    static func createQuestion(
        clubId: Int,
        content: String,
        anonymous: Bool = false
    ) async throws -> Int {
        let response = try await HTTPClient.shared.postJSON(
            basePath,
            body: QnACreateQuestionRequest(content: content, anonymous: anonymous),
            query: [URLQueryItem(name: "clubId", value: String(clubId))],
            as: QnACreateQuestionResponse.self
        )
        return response.questionId
    }

    static func updateQuestion(
        questionId: Int,
        content: String
    ) async throws {
        _ = try await HTTPClient.shared.patchJSONRaw(
            "\(basePath)/\(questionId)",
            body: QnAUpdateQuestionRequest(content: content)
        )
    }

    static func deleteQuestion(questionId: Int) async throws {
        _ = try await HTTPClient.shared.deleteRaw("\(basePath)/\(questionId)")
    }

    static func markQuestionAnswered(questionId: Int) async throws {
        _ = try await HTTPClient.shared.patchRaw("\(basePath)/\(questionId)/answered")
    }

    static func createAnswer(
        questionId: Int,
        content: String,
        anonymous: Bool = false,
        parentAnswerId: Int? = nil
    ) async throws -> Int {
        var query: [URLQueryItem] = []
        if let parentAnswerId {
            query.append(URLQueryItem(name: "parentsAnswerId", value: String(parentAnswerId)))
        }

        let response = try await HTTPClient.shared.postJSON(
            "\(basePath)/\(questionId)/answers",
            body: QnACreateAnswerRequest(content: content, anonymous: anonymous),
            query: query,
            as: QnACreateAnswerResponse.self
        )
        return response.answerId
    }

    static func deleteAnswer(answerId: Int) async throws {
        _ = try await HTTPClient.shared.deleteRaw("\(basePath)/answers/\(answerId)")
    }

    static func report(target: QnAReportTarget, reason: String) async throws {
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)

        _ = try await HTTPClient.shared.postJSONRaw(
            "\(basePath)/reports",
            body: QnAReportRequest(
                targetType: target.targetType,
                targetId: target.targetId,
                reason: trimmedReason
            )
        )
    }

    static func blockQuestionAuthor(questionId: Int) async throws {
        _ = try await HTTPClient.shared.postJSONRaw(
            "\(blockBasePath)/questions/\(questionId)",
            body: EmptyRequestBody()
        )
    }

    static func blockAnswerAuthor(answerId: Int) async throws {
        _ = try await HTTPClient.shared.postJSONRaw(
            "\(blockBasePath)/answers/\(answerId)",
            body: EmptyRequestBody()
        )
    }
}
