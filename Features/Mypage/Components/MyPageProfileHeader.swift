//
//  MyPageProfileHeader.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageProfileHeader: View {
    @Environment(\.appMetrics) private var m

    let profile: MyPageProfileUI?

    var body: some View {
        let nicknameHint = profile?.nicknameHint ?? "닉네임을 설정해보세요!"
        let name = profile?.name ?? "-"
        let studentId = profile?.studentId ?? "-"
        let major = profile?.majorDisplay ?? "-"
        let imageURL = profile?.profileImageURL

        let avatarW = 70 * m.scale
        let avatarH = 69 * m.scale

        return HStack(spacing: m.space16) {
            RoundedRectangle(cornerRadius: m.radius18)
                .fill(AppColors.fieldFill)
                .frame(width: avatarW, height: avatarH)
                .overlay {
                    if let imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Image(systemName: "person.fill")
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        .id(imageURL.absoluteString) // ✅ 추가: URL이 바뀌면 강제 리로드
                        .frame(width: avatarW, height: avatarH)
                        .clipShape(RoundedRectangle(cornerRadius: m.radius18))
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

            VStack(alignment: .leading, spacing: m.space4 + m.space2) {
                Text(nicknameHint)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                Text(name)
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)

                Text(major)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                Text(studentId)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer(minLength: 0)
        }
    }
}
