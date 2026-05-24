//
//  ClubListComponents.swift
//  UniClub

import SwiftUI

struct ClubListCard: View {
    @Environment(\.appMetrics) private var m
    let item: ClubsService.ClubDTO
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        // B-Clublist-4, 5: 하트/상태 라벨을 카드 외부 ZStack으로 배치
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomTrailing) {
                cardContent

                // B-Clublist-5: 상태 라벨 - 카드 외부 우하단
                if let statusText = ClubStatus(rawValue: item.status ?? "")?.displayText {
                    Text(statusText)
                        .font(AppTypography.notoSans(9, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.grey800.opacity(0.7))
                        .clipShape(Capsule())
                        .offset(x: 0, y: 12)
                }
            }

            // B-Clublist-4: 하트 - 카드 외부 우상단, 글로우 (tappable)
            heartButton
                .offset(x: 4, y: -10)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Card Content (without heart/status)

    private var cardContent: some View {
        HStack(spacing: m.space12) {
            avatar

            VStack(alignment: .leading, spacing: m.space8) {
                nameAndCategory
                descriptionText
            }
        }
        .padding(m.space14)
        .background(AppColors.brandLight)
        .clipShape(RoundedRectangle(cornerRadius: m.radiusClubCard))
        .shadow(radius: 10)
    }

    // MARK: - Name + Category Row

    private var nameAndCategory: some View {
        HStack(spacing: m.space8) {
            // B-Clublist-2: weight bold
            Text(item.name)
                .font(AppTypography.notoSans(14, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)

            categoryPill

            Spacer(minLength: 0)
        }
    }

    private var categoryPill: some View {
        // B-Clublist-3: #3C3C3C bg, r=5, 8pt
        Text(CategoryType(rawValue: item.category)?.displayText ?? "")
            .font(AppTypography.notoSans(8, weight: .medium))
            .foregroundStyle(.white.opacity(0.95))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: 0x3C3C3C))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private var descriptionText: some View {
        Text(item.info ?? "")
            .font(AppTypography.notoSans(9, weight: .medium))
            .foregroundStyle(.white.opacity(0.95))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Heart (B-Clublist-4, tappable)

    private var heartButton: some View {
        Button {
            onFavoriteTap?()
        } label: {
            Image(systemName: item.favorite ? "heart.fill" : "heart")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(item.favorite ? AppColors.error : .white.opacity(0.9))
                .shadow(
                    color: item.favorite ? Color(hex: 0xFFBFC7) : .clear,
                    radius: 4.1, x: 0, y: 0
                )
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(onFavoriteTap == nil)
    }

    // MARK: - Avatar

    private var avatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: m.radius20)
                .fill(.white)
                .frame(width: 54, height: 54)

            if let s = item.clubProfileUrl, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        AppColors.grey800.opacity(0.06)
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: m.radius20))
            } else {
                Image(systemName: "person.fill")
                    .foregroundStyle(AppColors.grey800.opacity(0.25))
            }
        }
    }
}
