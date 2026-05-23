//
//  NotificationRowView.swift
//  UniClub

import SwiftUI

struct NotificationRowView: View {
    @Environment(\.appMetrics) private var m

    let item: NotificationItem
    let onAction: () -> Void

    var body: some View {
        // B-Notification-5: 시스템 알림 별도 컴팩트 레이아웃
        Group {
            if item.type == .system {
                systemRow
            } else {
                standardRow
            }
        }
        // UX: 안읽은 알림 시각 표시 (좌측 brand 라인 + 불투명도)
        .overlay(alignment: .leading) {
            if !item.isRead {
                Rectangle()
                    .fill(AppColors.brand)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 1.5))
            }
        }
        .opacity(item.isRead ? 0.7 : 1.0)
    }

    // MARK: - Standard Row

    private var standardRow: some View {
        HStack(alignment: .top, spacing: m.space12) {
            typeIcon

            VStack(alignment: .leading, spacing: m.space6) {
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(AppTypography.notoSans(11, weight: .medium))
                        .foregroundStyle(AppColors.grey500)
                        .lineLimit(1)

                    Spacer(minLength: m.space8)

                    Text(item.receivedAt.relativeString)
                        .font(AppTypography.notoSans(10))
                        .foregroundStyle(AppColors.grey500)
                        .fixedSize()
                }

                Text(item.bodyWithEmoji)
                    .font(AppTypography.notoSans(12))
                    .foregroundStyle(AppColors.grey700)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let label = item.actionLabel {
                    Button(action: onAction) {
                        Text(label)
                            .font(AppTypography.notoSans(10, weight: .medium))
                            .foregroundStyle(AppColors.brand)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, m.space16)
        .padding(.vertical, m.space14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.background)
        // B-Notification-1: r=22
        .clipShape(RoundedRectangle(cornerRadius: m.radiusNotificationCard, style: .continuous))
        // B-Notification-2: card shadow
        .shadow(color: Color(hex: 0xB2B2B2).opacity(0.25), radius: 22.8, x: 0, y: 4)
    }

    // MARK: - System Row (B-Notification-5)

    private var systemRow: some View {
        HStack(spacing: m.space12) {
            ZStack {
                Circle()
                    .fill(Color(hex: 0x00BA5E))
                    .frame(width: 18, height: 18)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(item.body)
                .font(AppTypography.notoSans(12))
                .foregroundStyle(AppColors.grey700)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(item.receivedAt.relativeString)
                .font(AppTypography.notoSans(10))
                .foregroundStyle(AppColors.grey500)
                .fixedSize()
        }
        .padding(.horizontal, m.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 63)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: m.radiusNotificationCard, style: .continuous))
        .shadow(color: Color(hex: 0xB2B2B2).opacity(0.25), radius: 22.8, x: 0, y: 4)
    }

    // MARK: - Type Icon (B-Notification-3)

    private var typeIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackground)
                .frame(width: 32, height: 32)

            Image(systemName: item.type.iconSystemName)
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .medium))
        }
        .frame(width: 32, height: 32)
    }

    private var iconBackground: Color {
        switch item.type {
        case .recruitStart, .recruitEnd: return AppColors.brand
        case .answer, .question, .reply: return Color(hex: 0x5A7AFF)
        case .system:                    return Color(hex: 0x00BA5E)
        }
    }
}

// MARK: - Date helper

private extension Date {
    var relativeString: String {
        let diff = Int(Date.now.timeIntervalSince(self))
        if diff < 60 { return "방금 전" }
        if diff < 3600 { return "\(diff / 60)분 전" }
        if diff < 86400 { return "\(diff / 3600)시간 전" }
        return "\(diff / 86400)일 전"
    }
}

#Preview("NotificationRowView") {
    VStack(spacing: 8) {
        ForEach(NotificationItem.previews) { item in
            NotificationRowView(item: item, onAction: {})
        }
    }
    .padding()
    .background(AppColors.backgroundSecondary)
    .environment(\.appMetrics, .make(for: CGSize(width: 390, height: 844)))
}
