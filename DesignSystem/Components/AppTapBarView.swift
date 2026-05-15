//
//  AppTapBarView.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
import SwiftUI

public struct AppTabBar: View {
    @Environment(\.appMetrics) private var m
    @Binding private var selection: AppTab

    public init(selection: Binding<AppTab>) {
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            tabItem(.qna)
            tabItem(.home)
            tabItem(.mypage)
        }
        .padding(.horizontal, m.space12)
        .padding(.top, m.space10)
        .padding(.bottom, m.space10)
        .frame(maxWidth: .infinity)
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = (selection == tab)

        let labelSize: CGFloat = (tab == .qna) ? 11 : 10
        let kerning: CGFloat = (tab == .qna) ? -0.121 : -0.11
        let labelColor: Color = isSelected ? .white : AppColors.grey400

        return Button {
            selection = tab
        } label: {
            VStack(spacing: m.space4) {
                Image(tab.navIconAssetName(isSelected: isSelected))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24 * m.scale, height: 24 * m.scale)

                Text(tab.title)
                    .font(AppTypography.notoSans(labelSize * m.scale, weight: .medium))
                    .kerning(kerning * m.scale)
                    .foregroundStyle(labelColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: max(44, 56 * m.scale)) // ✅ 최소 44 보장
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
