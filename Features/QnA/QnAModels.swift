//
//  QnARoute.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import Foundation

// MARK: - Search

struct QnAQuestionSearchResponse: Decodable {
    let content: [QnAQuestionSummary]
    let hasNext: Bool
}

struct QnAQuestionSummary: Identifiable, Decodable, Hashable {
    let questionId: Int
    let nickname: String
    let clubName: String
    let content: String
    let owner: Bool
    let countAnswer: Int
    let updatedAt: String
    let profileURL: URL?
    let answered: Bool
    let president: Bool

    var id: Int { questionId }

    private enum CodingKeys: String, CodingKey {
        case questionId
        case nickname
        case clubName
        case content
        case owner
        case countAnswer
        case updatedAt
        case profile
        case answered
        case president
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionId = try container.decode(Int.self, forKey: .questionId)
        nickname = try container.decode(String.self, forKey: .nickname)
        clubName = try container.decode(String.self, forKey: .clubName)
        content = try container.decode(String.self, forKey: .content)
        owner = try container.decode(Bool.self, forKey: .owner)
        countAnswer = try container.decode(Int.self, forKey: .countAnswer)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        profileURL = try container.decodeOptionalURL(forKey: .profile)
        answered = (try? container.decode(Bool.self, forKey: .answered)) ?? false
        president = (try? container.decode(Bool.self, forKey: .president)) ?? false
    }
}

// MARK: - Detail

struct QnAQuestionDetail: Identifiable, Decodable, Hashable {
    let questionId: Int
    let nickname: String
    let clubName: String
    let content: String
    let anonymous: Bool
    let answered: Bool
    let updatedAt: String
    let owner: Bool
    let profileURL: URL?
    let president: Bool
    let answers: [QnAAnswerItem]

    var id: Int { questionId }

    private enum CodingKeys: String, CodingKey {
        case questionId
        case nickname
        case clubName
        case content
        case anonymous
        case answered
        case updatedAt
        case owner
        case profile
        case president
        case answers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionId = try container.decode(Int.self, forKey: .questionId)
        nickname = try container.decode(String.self, forKey: .nickname)
        clubName = try container.decode(String.self, forKey: .clubName)
        content = try container.decode(String.self, forKey: .content)
        anonymous = try container.decode(Bool.self, forKey: .anonymous)
        answered = try container.decode(Bool.self, forKey: .answered)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        owner = try container.decode(Bool.self, forKey: .owner)
        profileURL = try container.decodeOptionalURL(forKey: .profile)
        president = try container.decode(Bool.self, forKey: .president)
        answers = try container.decode([QnAAnswerItem].self, forKey: .answers)
    }
}

struct QnAAnswerItem: Identifiable, Decodable, Hashable {
    let answerId: Int
    let nickname: String
    let content: String
    let anonymous: Bool
    let deleted: Bool
    let updateTime: String
    let parentAnswerId: Int?
    let owner: Bool
    let president: Bool
    let profileURL: URL?

    var id: Int { answerId }

    private enum CodingKeys: String, CodingKey {
        case answerId
        case nickname
        case content
        case anonymous
        case deleted
        case updateTime
        case parentAnswerId
        case owner
        case president
        case profile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        answerId = try container.decode(Int.self, forKey: .answerId)
        nickname = try container.decode(String.self, forKey: .nickname)
        content = try container.decode(String.self, forKey: .content)
        anonymous = try container.decode(Bool.self, forKey: .anonymous)
        deleted = try container.decode(Bool.self, forKey: .deleted)
        updateTime = try container.decode(String.self, forKey: .updateTime)
        parentAnswerId = try container.decodeIfPresent(Int.self, forKey: .parentAnswerId)
        owner = try container.decode(Bool.self, forKey: .owner)
        president = try container.decode(Bool.self, forKey: .president)
        profileURL = try container.decodeOptionalURL(forKey: .profile)
    }
}

// MARK: - Clubs

struct QnAClubSummary: Identifiable, Decodable, Hashable {
    let clubId: Int
    let clubName: String
    let categoryType: String

    var id: Int { clubId }

    var categoryDisplayName: String {
        switch categoryType {
        case "ACADEMIC_EDUCATION", "LIBERAL_ACADEMIC", "IT_TECH": return "교양학술"
        case "ART_CULTURE", "CULTURE": return "문화"
        case "SPORTS": return "체육"
        case "RELIGION": return "종교"
        case "VOLUNTEER": return "봉사"
        case "HOBBY_EXHIBITION": return "취미전시"
        default: return categoryType
        }
    }
}

// MARK: - Requests / Responses

struct QnACreateQuestionRequest: Encodable {
    let content: String
    let anonymous: Bool
}

struct QnACreateQuestionResponse: Decodable {
    let questionId: Int
}

struct QnAUpdateQuestionRequest: Encodable {
    let content: String
}

struct QnACreateAnswerRequest: Encodable {
    let content: String
    let anonymous: Bool
}

struct QnACreateAnswerResponse: Decodable {
    let answerId: Int
}

enum QnAReportTargetType: String, Encodable {
    case question = "QUESTION"
    case answer = "ANSWER"
}

enum QnAReportTarget: Equatable {
    case question(id: Int)
    case answer(id: Int)

    var targetType: QnAReportTargetType {
        switch self {
        case .question:
            return .question
        case .answer:
            return .answer
        }
    }

    var targetId: Int {
        switch self {
        case .question(let id):
            return id
        case .answer(let id):
            return id
        }
    }

    var dialogTitle: String {
        switch self {
        case .question:
            return "이 질문을 신고하시겠습니까?"
        case .answer:
            return "이 답변을 신고하시겠습니까?"
        }
    }
}

struct QnAReportRequest: Encodable {
    let targetType: QnAReportTargetType
    let targetId: Int
    let reason: String
}

// MARK: - Helpers

enum QnADateFormatter {
    private static let inputFormatterWithMicroseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let inputFormatterWithMilliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let inputFormatterWithoutFraction: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd  HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    static func display(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let date = inputFormatterWithMicroseconds.date(from: trimmed) {
            return outputFormatter.string(from: date)
        }

        if let date = inputFormatterWithMilliseconds.date(from: trimmed) {
            return outputFormatter.string(from: date)
        }

        if let date = inputFormatterWithoutFraction.date(from: trimmed) {
            return outputFormatter.string(from: date)
        }

        return raw
    }
}
private extension KeyedDecodingContainer {
    func decodeOptionalURL(forKey key: Key) throws -> URL? {
        let rawValue = try decodeIfPresent(String.self, forKey: key)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let rawValue, !rawValue.isEmpty, let url = URL(string: rawValue) else {
            return nil
        }
        return url
    }
}
