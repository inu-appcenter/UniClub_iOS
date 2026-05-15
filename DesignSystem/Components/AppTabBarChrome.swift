//
//  AppTabBarChrome.swift
//  UniClub
//

import SwiftUI

public struct AppTabBarChrome: View {
    @Environment(\.appMetrics) private var m
    @Binding private var selection: AppTab

    private let isHidden: Bool

    private var barHeight: CGFloat { 89 * m.scale }

    public init(
        selection: Binding<AppTab>,
        isHidden: Bool
    ) {
        self._selection = selection
        self.isHidden = isHidden
    }

    public var body: some View {
        AppTabBar(selection: $selection)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(tabBarBackground)
            .offset(y: isHidden ? (barHeight + 10) : 0)
            .animation(.easeInOut(duration: 0.18), value: isHidden)
    }

    private var tabBarBackground: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: AppColors.grey800.opacity(0.00), location: 0.00),
                    .init(color: AppColors.grey800.opacity(0.45), location: 0.35),
                    .init(color: AppColors.grey800.opacity(0.78), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                stops: [
                    .init(color: AppColors.background.opacity(0.50), location: 0.0),
                    .init(color: AppColors.background.opacity(0.18), location: 0.20),
                    .init(color: AppColors.background.opacity(0.00), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 70 * m.scale)
            .blur(radius: 10 * m.scale)
            .opacity(0.9)
            .allowsHitTesting(false)
        }
        .clipShape(Rectangle())
    }
}
