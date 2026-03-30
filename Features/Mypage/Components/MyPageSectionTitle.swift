//
//  MyPageSectionTitle.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(AppColors.textPrimary)
    }
}
