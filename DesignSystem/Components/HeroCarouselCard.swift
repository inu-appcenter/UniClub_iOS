//
//  HeroCarouselCard.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct HeroCarouselCard: View {
    @Environment(\.appMetrics) private var m

    private let title: String
    private let subtitle: String?
    private let imageURL: URL?
    private let onTap: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        imageURL: URL? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.onTap = onTap
    }

    public var body: some View {
        let card = ZStack(alignment: .bottomLeading) {
            cover

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: m.space8) {
                Text(title)
                    .font(AppTypography.title())
                    .foregroundStyle(Color.white)
                    .lineLimit(2)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.caption())
                        .foregroundStyle(Color.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .padding(m.space16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 249) // matches typical Figma hero height (can be overridden by parent)
        .clipShape(RoundedRectangle(cornerRadius: m.radius18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: m.radius18, style: .continuous)
                .stroke(AppColors.border.opacity(0.25), lineWidth: m.hairline)
        )

        if let onTap {
            Button(action: onTap) { card }
                .buttonStyle(.plain)
        } else {
            card
        }
    }

    @ViewBuilder
    private var cover: some View {
        if let imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(AppColors.cardFill)
            .overlay(
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            )
            .clipped()
    }
}
