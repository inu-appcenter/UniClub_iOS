//
//  InquiryView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

struct ContactUsView: View {
    @Environment(\.appMetrics) private var m
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let kakaoUrlString = "https://pf.kakao.com/_xgxaSLd"
    private let instagramHandle = "@inuappcenter"
    private let instagramUrlString = "https://instagram.com/inuappcenter"
    private let emailAddress = "inuappcenter@gamil.com"

    private var contentHorizontalInset: CGFloat { m.space18 }

    var body: some View {
        ScreenContainer(
            scroll: false,
            topPadding: .none,
            bottomPadding: .default
        ) { _ in
            VStack(spacing: 0) {
                AppPageHeader(onBack: { dismiss() }) {
                    Text("문의하기")
                        .font(AppTypography.notoSans(15, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                }

                guideText
                    .padding(.top, m.scale * 22)
                    .padding(.horizontal, contentHorizontalInset)

                contactList
                    .padding(.top, m.space28)
                    .padding(.horizontal, contentHorizontalInset)

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Guide
    private var guideText: some View {
        Text("UniClub 이용 중에 생긴 불편한 점이나 문의사항을 \n보내주세요 :-)")
            .font(AppTypography.notoSans(11 * m.scale))
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.leading)
            .lineSpacing(4 * m.scale)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Contact List
    private var contactList: some View {
        VStack(alignment: .leading, spacing: m.scale * 26) {
            contactItemWithButton(
                title: "Kakao Talk 채널",
                value: "pf.kakao.com/_xgxaSLd",
                onTap: {
                    if let url = URL(string: kakaoUrlString) {
                        openURL(url)
                    }
                }
            )

            contactItemWithButton(
                title: "Instagram",
                value: instagramHandle,
                onTap: {
                    if let url = URL(string: instagramUrlString) {
                        openURL(url)
                    }
                }
            )

            contactItemWithoutButton(
                title: "Email",
                value: emailAddress
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func contactItemWithButton(
        title: String,
        value: String,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 12 * m.scale) {
            VStack(alignment: .leading, spacing: 4 * m.scale) {
                Text(title)
                    .font(AppTypography.notoSans(14 * m.scale, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)

                Text(value)
                    .font(AppTypography.notoSans(10 * m.scale))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)

            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0))

                    Image(systemName: "chevron.right")
                        .font(AppTypography.notoSans(14 * m.scale, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 34 * m.scale, height: 34 * m.scale)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func contactItemWithoutButton(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4 * m.scale) {
            Text(title)
                .font(AppTypography.notoSans(14 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Text(value)
                .font(AppTypography.notoSans(10 * m.scale))
                .foregroundStyle(AppColors.textSecondary)
                .onTapGesture {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = value
                    #endif
                }
        }
    }
}

#Preview {
    NavigationStack {
        ContactUsView()
    }
}
