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

    private var contentHorizontalInset: CGFloat { 36 * m.scale }

    var body: some View {
        ScreenContainer(
            scroll: false,
            topPadding: .none,
            bottomPadding: .default
        ) { _ in
            VStack(spacing: 0) {
                header
                    .padding(.top, 8 * m.scale)

                guideText
                    .padding(.top, 40 * m.scale)
                    .padding(.horizontal, contentHorizontalInset)

                contactList
                    .padding(.top, 48 * m.scale)
                    .padding(.horizontal, contentHorizontalInset)

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18 * m.scale, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44 * m.scale, height: 44 * m.scale)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("문의하기")
                .font(.system(size: 15 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 44 * m.scale, height: 44 * m.scale)
        }
        .padding(.horizontal, 8 * m.scale)
        .frame(height: 44 * m.scale)
    }

    // MARK: - Guide
    private var guideText: some View {
        Text("UniClub 이용 중에 생긴 불편한 점이나 문의사항을 \n보내주세요 :-)")
            .font(.system(size: 11 * m.scale, weight: .regular))
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.leading)
            .lineSpacing(4 * m.scale)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Contact List
    private var contactList: some View {
        VStack(alignment: .leading, spacing: 32 * m.scale) {
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
                    .font(.system(size: 14 * m.scale, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)

                Text(value)
                    .font(.system(size: 10 * m.scale, weight: .regular))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)

            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14 * m.scale, weight: .bold))
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
                .font(.system(size: 14 * m.scale, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Text(value)
                .font(.system(size: 10 * m.scale, weight: .regular))
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
