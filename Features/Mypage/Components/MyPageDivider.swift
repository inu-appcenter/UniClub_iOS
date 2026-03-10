//
//  MyPageDivider.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageDivider: View {
    @Environment(\.appMetrics) private var m

    var body: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(height: m.hairline)
            .opacity(0.75)
    }
}
