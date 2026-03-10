//
//  ClubListComponents.swift
//  UniClub
//
//  Created by 제욱 on 2/9/26.
//

import SwiftUI

struct ClubListCard: View {
    @Environment(\.appMetrics) private var m
    let item: ClubsService.ClubDTO

    var body: some View {
        HStack(spacing: m.space12) {
            avatar

            VStack(alignment: .leading, spacing: m.space8) {
                topRow
                descriptionText
                bottomRow
            }
        }
        .padding(m.space14)
        .background(AppColors.brand) // ✅ 카드 배경(주황) — 토큰 확정되면 교체
        .clipShape(RoundedRectangle(cornerRadius: 28)) // TODO: AppMetrics에 radius28 토큰 생기면 교체
        .shadow(radius: 10)
    }

    // MARK: - Rows

    private var topRow: some View {
        HStack(spacing: m.space8) {
            // 이름: 14pt (JSON 기반)
            Text(item.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)

            categoryPill

            Spacer(minLength: 0)

            Image(systemName: item.favorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(item.favorite ? .pink : .white.opacity(0.95))
        }
    }

    private var categoryPill: some View {
        Text(CategoryType(rawValue: item.category)?.displayText ?? "")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white.opacity(0.95))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.28))
            .clipShape(Capsule())
    }

    private var descriptionText: some View {
        // 소개: 9pt (JSON 기반)
        Text(item.info ?? "")
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(.white.opacity(0.95))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var bottomRow: some View {
        HStack(spacing: m.space8) {
            Spacer(minLength: 0)

            if statusDotVisible {
                Circle()
                    .fill(.green)
                    .frame(width: 3, height: 3)
            }

            // 상태: 10pt (JSON 기반)
            Text(ClubStatus(rawValue: item.status ?? "")?.displayText ?? "")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
        }
    }

    private var statusDotVisible: Bool {
        // 서버 enum: SCHEDULED / ACTIVE / CLOSED
        ClubStatus(rawValue: item.status ?? "") == .active
    }

    // MARK: - Avatar

    private var avatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: 54, height: 54)

            if let s = item.clubProfileUrl, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Color.black.opacity(0.06)
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Image(systemName: "person.fill")
                    .foregroundStyle(Color.black.opacity(0.25))
            }
        }
    }
}

struct ClubListSortButton: View {
    @Environment(\.appMetrics) private var m

    let selected: SortOption
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: m.space8) {
                Text("정렬순")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textPrimary)

                Text(selected.rawValue)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, m.space12)
            .padding(.vertical, m.space10)
            .background(AppColors.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
            .overlay(
                RoundedRectangle(cornerRadius: m.radius18)
                    .stroke(AppColors.border, lineWidth: m.hairline)
            )
        }
        .buttonStyle(.plain)
    }
}
