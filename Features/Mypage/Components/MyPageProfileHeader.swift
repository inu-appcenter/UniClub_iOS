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
        let nicknameText = profile?.nicknameText ?? "닉네임을 설정해보세요!"
        let hasNickname = profile?.hasNickname ?? false
        let name = profile?.name ?? "-"
        let studentId = profile?.studentId ?? "-"
        let major = profile?.majorDisplay ?? "-"
        let imageURL = profile?.profileImageURL

        let avatarW = 70 * m.scale
        let avatarH = 69 * m.scale
        let avatarRadius: CGFloat = 23 * m.scale

        return HStack(alignment: .center, spacing: m.space16) {
            RoundedRectangle(cornerRadius: avatarRadius)
                .fill(AppColors.fieldFill)
                .frame(width: avatarW, height: avatarH)
                .overlay {
                    if let imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()

                            default:
                                Image("image_default_mypage")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .id(imageURL.absoluteString)
                        .frame(width: avatarW, height: avatarH)
                        .clipShape(RoundedRectangle(cornerRadius: avatarRadius))
                    } else {
                        Image("image_default_mypage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: avatarW, height: avatarH)
                            .clipShape(RoundedRectangle(cornerRadius: avatarRadius))
                    }
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(nicknameText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(hasNickname ? AppColors.textSecondary : Color(red: 0.827, green: 0.827, blue: 0.827))
                    .padding(.bottom, 4 * m.scale)

                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.bottom, 9 * m.scale)

                Text(major)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(red: 0.505, green: 0.505, blue: 0.505))
                    .padding(.bottom, 5 * m.scale)

                Text(studentId)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color(red: 0.505, green: 0.505, blue: 0.505))
            }

            Spacer(minLength: 0)
        }
    }
}
