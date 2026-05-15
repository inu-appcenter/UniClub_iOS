//
//  NotificationRowView.swift
//  UniClub

import SwiftUI

struct NotificationRowView: View {
    @Environment(\.appMetrics) private var m

    let item: NotificationItem
    let onAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: m.space12) {
            clubIcon

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
        .clipShape(RoundedRectangle(cornerRadius: m.radius12, style: .continuous))
    }

    // 빨간 원형 아이콘 (동아리 로고 자리)
    private var clubIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.error)
                .frame(width: 32, height: 32)

            // 시스템 알림만 경고 아이콘
            if item.type == .system {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
                    .font(AppTypography.notoSans(14, weight: .bold))
            }
        }
        .frame(width: 32, height: 32)
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
