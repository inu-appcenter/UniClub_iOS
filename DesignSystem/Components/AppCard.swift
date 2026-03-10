//
//  AppCard.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct AppCard<Content: View>: View {
    @Environment(\.appMetrics) private var m
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(m.space16)
            .background(AppColors.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: m.radius18))
            .overlay(
                RoundedRectangle(cornerRadius: m.radius18)
                    .stroke(AppColors.border, lineWidth: m.hairline)
            )
    }
}
