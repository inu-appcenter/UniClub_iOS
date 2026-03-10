//
//  DesignToken.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

enum DesignColor {
    static let background = Color.white
    static let primary = Color(red: 1.0, green: 0.35, blue: 0.0)
    static let grayLine = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let fieldBG = Color(red: 0.91, green: 0.91, blue: 0.91)
    static let buttonBG = Color.black
}

@inline(__always)
func clamp(_ v: CGFloat, _ minV: CGFloat, _ maxV: CGFloat) -> CGFloat {
    Swift.min(Swift.max(v, minV), maxV)
}

@inline(__always)
func scaled(_ base: CGFloat, by factor: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    clamp(base * factor, min, max)
}
