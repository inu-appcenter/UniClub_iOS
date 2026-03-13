//
//  QnAAnswerRow.swift
//  UniClub
//
//  Created by 제욱 on 3/10/26.
//

import SwiftUI

struct QnAAnswerRow: View {
    @Environment(\.appMetrics) private var m

    let answer: QnAAnswerItem
    let indentLevel: Int
    let isReplyTarget: Bool
    let onTapReply: (() -> Void)?
    let onTapMore: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: m.space10) {
            HStack(alignment: .top, spacing: m.space10) {
                avatarView(size: m.space28 + m.space4)

                VStack(alignment: .leading, spacing: m.space2) {
                    HStack(spacing: m.space4) {
                        Text(answer.nickname)
                            .font(AppTypography.bodyStrong())
                            .foregroundStyle(AppColors.textPrimary)

                        if answer.president {
                            Circle()
                                .fill(Color(hex: 0xFF5900))
                                .frame(width: m.space6, height: m.space6)
                        }
                    }

                    Text(QnADateFormatter.display(answer.updateTime))
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer(minLength: 0)

                if let onTapMore {
                    Button(action: onTapMore) {
                        Image(systemName: "ellipsis")
                            .rotationEffect(Angle(degrees: 90))
                            .font(.system(size: m.space18, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(alignment: .bottom, spacing: m.space10) {
                Text(answer.deleted ? "삭제된 댓글입니다." : answer.content)
                    .font(AppTypography.body())
                    .foregroundStyle(answer.deleted ? Color(hex: 0xBFBFBF) : AppColors.textPrimary)
                    .padding(.leading, m.space28 + m.space10 + m.space4)

                Spacer(minLength: 0)

                if let onTapReply, !answer.deleted {
                    Button("답글쓰기") {
                        onTapReply()
                    }
                    .font(AppTypography.caption())
                    .foregroundStyle(Color(hex: 0xBFBFBF))
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(m.space14)
        .background(isReplyTarget ? Color(hex: 0xE3E3E3) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: m.radius16, style: .continuous)
                .stroke(
                    isReplyTarget ? Color(hex: 0xCACACA) : Color.clear,
                    lineWidth: 0.5
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: m.radius16, style: .continuous))
        .padding(.leading, CGFloat(indentLevel) * (m.space16 + m.space4))
    }

    @ViewBuilder
    private func avatarView(size: CGFloat) -> some View {
        if let profileURL = answer.profileURL {
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
