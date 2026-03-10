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

    // JSON 그대로 (Email은 gamil로 되어있음)
    private let kakaoUrlString = "https://pf.kakao.com/_xgxaSLd"
    private let instagramHandle = "@inuappcenter"
    private let instagramUrlString = "https://instagram.com/inuappcenter"
    private let emailAddress = "inuappcenter@gamil.com"

    var body: some View {
        ScreenContainer(scroll: false) { _ in
            VStack(spacing: 0) {
                header
                    .padding(.top, m.space8)

                안내문구
                    .padding(.top, 22)

                VStack(spacing: 18) {
                    contactRow(
                        title: "Kakao Talk 채널",
                        value: "pf.kakao.com/_xgxaSLd",
                        actionTitle: "열기",
                        onTap: {
                            if let url = URL(string: kakaoUrlString) { openURL(url) }
                        }
                    )

                    contactRow(
                        title: "Instagram",
                        value: instagramHandle,
                        actionTitle: "열기",
                        onTap: {
                            if let url = URL(string: instagramUrlString) { openURL(url) }
                        }
                    )

                    contactRow(
                        title: "Email",
                        value: emailAddress,
                        actionTitle: "복사",
                        onTap: {
                            #if canImport(UIKit)
                            UIPasteboard.general.string = emailAddress
                            #endif
                        }
                    )
                }
                .padding(.top, 44)
                .padding(.horizontal, 24)

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 0) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("문의하기")
                .font(AppTypography.bodyStrong())
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, m.space8)
        .frame(height: 44)
    }

    // MARK: - 안내 문구
    private var 안내문구: some View {
        Text("UniClub 이용 중에 생긴 불편한 점이나 문의사항을 \n보내주세요 :-)")
            .font(AppTypography.caption())
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }

    // MARK: - Row
    private func contactRow(
        title: String,
        value: String,
        actionTitle: String,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(AppTypography.body())
                    .foregroundStyle(AppColors.textPrimary)

                Text(value)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)

            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0)) // JSON의 주황 포인트
                        .frame(width: 34, height: 34)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(actionTitle)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: m.radius18))
        .overlay(
            RoundedRectangle(cornerRadius: m.radius18)
                .stroke(AppColors.border, lineWidth: m.hairline)
        )
    }
}

#Preview {
    NavigationStack {
        ContactUsView()
    }
}
