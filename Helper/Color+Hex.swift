//
//  Color+Hex.swift
//  UniClub
//
//  Created by 제욱 on 2/8/26.
//

import SwiftUI

extension Color {
    /// 예: Color(hex: 0xFF5900)
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
