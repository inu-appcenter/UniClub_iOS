//
//  MyPageGuideSection.swift
//  UniClub
//
//  Created by 제욱 on 2/10/26.
//

import SwiftUI

struct MyPageGuideSection: View {
    @Environment(\.openURL) private var openURL

    let onInquiry: () -> Void

    private let termsURL = URL(string: "https://www.notion.so/UniClub-2b618a113ff5807b81d3faa6d09494ac?source=copy_link")!

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MyPageSectionTitle(title: "이용안내")
            MyPageMenuRow(title: "문의하기", action: onInquiry)
            MyPageMenuRow(title: "이용약관", action: {
                openURL(termsURL)
            })
        }
    }
}
