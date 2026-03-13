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
    let onTap: () -> Void
    let onMore: (() -> Void)?

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: m.space10) {
                HStack(alignment: .top, spacing: m.space10) {
                    avatarView(size: m.space32)

                    VStack(alignment: .leading, spacing: m.space2) {
                        Text(nickname)
                            .font(AppTypography.bodyStrong())
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)

                        Text(QnADateFormatter.display(updatedAt))
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: 0)

                    if let onMore {
                        Button(action: onMore) {
                            Image(systemName: "ellipsis")
                                .rotationEffect(Angle(degrees: 90))
                                .font(.system(size: m.space18, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(width: m.controlHeight44, height: m.controlHeight44)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("@\(clubName)")
                    .font(AppTypography.captionStrong())
                    .foregroundStyle(Color(hex: 0xFF5900))
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
                        .foregroundStyle(Color.orange)
                }
            }
            .padding(m.space16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: m.radius18, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 2)
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
