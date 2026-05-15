//
//  ClubCard.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct ClubCard: View {
    @Environment(\.appMetrics) private var m

    private let name: String
    private let statusText: String?
    private let imageURL: URL?
    private let tags: [String]
    private let onTap: (() -> Void)?

    public init(
        name: String,
        statusText: String? = nil,
        imageURL: URL? = nil,
        tags: [String] = [],
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.statusText = statusText
        self.imageURL = imageURL
        self.tags = tags
        self.onTap = onTap
    }

    public var body: some View {
        let content = AppCard {
            VStack(alignment: .leading, spacing: m.space12) {
                ZStack(alignment: .topTrailing) {
                    cover
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: m.radius16, style: .continuous))

                    if let statusText {
                        Text(statusText)
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, m.space10)
                            .padding(.vertical, m.space8)
                            .background(AppColors.background.opacity(0.9))
                            .clipShape(Capsule())
                            .padding(m.space10)
                    }
                }

                Text(name)
                    .font(AppTypography.bodyStrong())
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: m.space8) {
                            ForEach(tags, id: \.self) { t in
                                Chip(t)
                            }
                        }
                    }
                }
            }
        }

        if let onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
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
        RoundedRectangle(cornerRadius: m.radius16, style: .continuous)
            .fill(AppColors.cardFill)
            .overlay(
                Image(systemName: "photo")
                    .font(AppTypography.notoSans(18))
                    .foregroundStyle(AppColors.textSecondary)
            )
            .clipped()
    }
}
