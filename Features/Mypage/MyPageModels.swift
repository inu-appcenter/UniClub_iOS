//
//  MypageModels.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import Foundation

struct MyPageProfileUI: Equatable {
    let nicknameText: String
    let hasNickname: Bool
    let name: String
    let studentId: String
    let majorDisplay: String
    let profileImageURL: URL?

    static func from(_ dto: UserMeResponse) -> MyPageProfileUI {
        let trimmedNickname = dto.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasNickname = !trimmedNickname.isEmpty
        let nicknameText = hasNickname ? trimmedNickname : "닉네임을 설정해보세요!"

        let majorDisplay = MajorCatalog.all.first(where: { $0.code == dto.major })?.display ?? dto.major

        let url: URL?
        let raw = (dto.profileImageLink ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty {
            url = nil
        } else if raw.hasPrefix("http") {
            url = URL(string: raw)
        } else {
            url = URL(string: AppConfig.baseURL.absoluteString + "/" + raw)
        }

        return .init(
            nicknameText: nicknameText,
            hasNickname: hasNickname,
            name: dto.name.isEmpty ? "-" : dto.name,
            studentId: dto.studentId.isEmpty ? "-" : dto.studentId,
            majorDisplay: majorDisplay.isEmpty ? "-" : majorDisplay,
            profileImageURL: url
        )
    }
}
