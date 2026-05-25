//
//  QnAQuestionCard.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import SwiftUI

struct QnAQuestionCard: View {
    @Environment(\.appMetrics) private var m

    let profileURL: URL?
    let nickname: String
    let updatedAt: String
    let clubName: String
    let content: String
    let answerCount: Int
    let isAnswered: Bool
    let isPresident: Bool
    let onTap: () -> Void
    let onMore: (() -> Void)?

    init(
        profileURL: URL?,
        nickname: String,
        updatedAt: String,
        clubName: String,
        content: String,
        answerCount: Int,
        isAnswered: Bool = false,
        isPresident: Bool = false,
        onTap: @escaping () -> Void,
        onMore: (() -> Void)? = nil
    ) {
        self.profileURL = profileURL
        self.nickname = nickname
        self.updatedAt = updatedAt
        self.clubName = clubName
        self.content = content
        self.answerCount = answerCount
        self.isAnswered = isAnswered
        self.isPresident = isPresident
        self.onTap = onTap
        self.onMore = onMore
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: m.space10) {
                avatarView(size: m.space32)

                VStack(alignment: .leading, spacing: m.space6) {
                    VStack(alignment: .leading, spacing: m.space2) {
                        Text(nickname)
                            .font(AppTypography.bodyStrong())
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)

                        Text(QnADateFormatter.display(updatedAt))
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Text("@\(clubName)")
                        .font(AppTypography.captionStrong())
                        .foregroundStyle(AppColors.brand)
                        .lineLimit(1)

                    Text(content)
                        .font(AppTypography.body())
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: m.space6) {
                        Image("icon_qna_answer_count")
                            .resizable()
                            .scaledToFit()
                            .frame(width: m.space14, height: m.space14)

                        Text("\(answerCount)")
                            .font(AppTypography.captionStrong())
                            .foregroundStyle(AppColors.brand)
                    }
                }
                .padding(.trailing, m.space32)
            }
            .padding(m.space16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 더보기 버튼: Figma 기준 카드 상단 17pt, 우측 22pt
            if let onMore {
                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(Angle(degrees: 90))
                        .font(AppTypography.notoSans(m.space18, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: m.controlHeight44)
                }
                .buttonStyle(.plain)
                .padding(.top, 17)
                .padding(.trailing, 22)
            }

            // B-QnA-3: 답변 완료 뱃지 (회장 권한 표시 또는 답변 상태)
            if isPresident || isAnswered {
                Text(isAnswered ? "답변완료" : "미답변")
                    .font(AppTypography.notoSans(9, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(isAnswered ? AppColors.brand : Color(hex: 0xD9D9D9))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .padding(.top, m.space8)
                    .padding(.trailing, m.space8)
            }
            }  // ZStack
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: m.radiusQnACard, style: .continuous))
            .shadow(color: Color(hex: 0xB3B3B5).opacity(0.25), radius: 11.4, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func avatarView(size: CGFloat) -> some View {
        if let profileURL {
            AsyncImage(url: profileURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    defaultAvatar(size: size)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            defaultAvatar(size: size)
        }
    }

    private func defaultAvatar(size: CGFloat) -> some View {
        Image("image_default_user")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
