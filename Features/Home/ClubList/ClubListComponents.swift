//
//  ClubListComponents.swift
//  UniClub

import SwiftUI

struct ClubListCard: View {
    @Environment(\.appMetrics) private var m
    let item: ClubsService.ClubDTO
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .overlay(alignment: .bottomTrailing) {
                    if let status = ClubStatus(rawValue: item.status ?? "") {
                        statusBadge(for: status)
                            .padding(.trailing, m.space20)
                            .padding(.bottom, 8)
                    }
                }

            heartButton
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        HStack(alignment: .top, spacing: m.space20) {
            avatar

            VStack(alignment: .leading, spacing: m.space4) {
                nameAndCategory
                descriptionText
            }
        }
        .padding(m.space8)
        .background(AppColors.brandCardFill)
        .clipShape(RoundedRectangle(cornerRadius: m.radiusClubCard))
        .shadow(color: .black.opacity(0.25), radius: 13.4, x: 0, y: 0)
    }

    // MARK: - Name + Category Row

    private var nameAndCategory: some View {
        HStack(spacing: m.space8) {
            Text(item.name)
                .font(AppTypography.notoSans(14, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 0)

            categoryPill

            Spacer(minLength: 0)
        }
    }

    private var categoryPill: some View {
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

    // MARK: - Heart

    private var heartButton: some View {
        Button {
            onFavoriteTap?()
        } label: {
            Image(systemName: "heart.fill")
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
        .padding(.top, m.space8)
        .padding(.bottom, m.space8)
        .padding(.leading, m.space8)
        .padding(.trailing, m.space20)
    }

    // MARK: - Status Badge

    @ViewBuilder
    private func statusBadge(for status: ClubStatus) -> some View {
        switch status {
        case .active:
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(red: 0, green: 1, blue: 0.067))
                    .frame(width: 3, height: 3)
                Text(status.displayText)
                    .font(AppTypography.notoSans(10, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
            }
        case .scheduled, .closed:
            Text(status.displayText)
                .font(AppTypography.notoSans(10, weight: .medium))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 0)
        }
    }

    // MARK: - Avatar

    private var avatar: some View {
        ZStack {
            if let s = item.clubProfileUrl, let url = URL(string: s) {
                RoundedRectangle(cornerRadius: m.radius20)
                    .fill(.white)
                    .frame(width: 54 * m.scale, height: 53 * m.scale)
                    .shadow(color: .black.opacity(0.25), radius: 3.6, x: 0, y: 0)

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Image("image_default_clublist")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 54 * m.scale, height: 53 * m.scale)
                .clipShape(RoundedRectangle(cornerRadius: m.radius20))
            } else {
                Image("image_default_clublist")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54 * m.scale, height: 53 * m.scale)
                    .clipShape(RoundedRectangle(cornerRadius: m.radius20))
            }
        }
    }
}
