//
//  NotificationRowView.swift
//  UniClub

import SwiftUI

struct NotificationRowView: View {
    @Environment(\.appMetrics) private var m

    let item: NotificationItem
    let actionLabel: String?
    let swipeLabel: String
    let onAction: () -> Void
    let onSwipeAction: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showButton = false
    private let swipeButtonWidth: CGFloat = 95
    private let swipeGap: CGFloat = 14
    private var swipeTotal: CGFloat { swipeButtonWidth + swipeGap }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                if showButton || offset < 0 {
                    swipeButton
                        .frame(width: swipeButtonWidth, height: geo.size.height)
                }

                cardContent
                    .offset(x: offset)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                let translation = value.translation.width
                                if translation < 0 {
                                    offset = max(translation, -swipeTotal)
                                } else if showButton {
                                    offset = min(0, -swipeTotal + translation)
                                }
                            }
                            .onEnded { value in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    if offset < -swipeTotal / 2 {
                                        offset = -swipeTotal
                                        showButton = true
                                    } else {
                                        offset = 0
                                        showButton = false
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: intrinsicHeight)
    }

    private var intrinsicHeight: CGFloat {
        actionLabel != nil ? 84 : 70
    }

    // MARK: - Swipe Button (Figma: 95×h, #FF5900, r=19)

    private var swipeButton: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                offset = 0
                showButton = false
            }
            onSwipeAction()
        }) {
            Text(swipeLabel)
                .font(AppTypography.notoSans(11, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: swipeButtonWidth, height: intrinsicHeight)
                .background(AppColors.brand)
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card Content

    private var cardContent: some View {
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

                Text(item.body)
                    .font(AppTypography.notoSans(12))
                    .foregroundStyle(AppColors.grey700)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let label = actionLabel {
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
        .clipShape(RoundedRectangle(cornerRadius: m.radiusNotificationCard, style: .continuous))
        .shadow(color: Color(hex: 0xB2B2B2).opacity(0.25), radius: 22.8, x: 0, y: 4)
    }

    // MARK: - Type Icon

    private var typeIcon: some View {
        Image(item.type.iconAssetName)
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(width: 22, height: 22)
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
