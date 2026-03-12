//
//  AppMetrics.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct AppMetrics: Equatable {
    public let screenSize: CGSize
    public let scale: CGFloat

    // Layout constraints
    public let contentMaxWidth: CGFloat
    public let horizontalPadding: CGFloat

    // Spacing tokens
    public let space2: CGFloat
    public let space4: CGFloat
    public let space6: CGFloat
    public let space8: CGFloat
    public let space10: CGFloat
    public let space12: CGFloat
    public let space14: CGFloat
    public let space16: CGFloat
    public let space18: CGFloat
    public let space20: CGFloat
    public let space24: CGFloat
    public let space28: CGFloat
    public let space32: CGFloat
    public let space44: CGFloat

    // Radius tokens
    public let radius12: CGFloat
    public let radius16: CGFloat
    public let radius18: CGFloat
    public let radius24: CGFloat
    public let radiusPill: CGFloat

    // Control tokens
    public let controlHeight44: CGFloat
    public let controlHeight48: CGFloat
    public let controlHeight52: CGFloat

    // Stroke
    public let hairline: CGFloat

    public static func make(for size: CGSize,
                            baseWidth: CGFloat = 360,
                            scaleMin: CGFloat = 0.95,
                            scaleMax: CGFloat = 1.12,
                            contentMaxWidth: CGFloat = 480) -> AppMetrics {
        let raw = size.width / baseWidth
        let s = min(max(raw, scaleMin), scaleMax)

        func scaled(_ v: CGFloat) -> CGFloat { v * s }

        // 핵심: “퍼짐” 제한
        let maxW = min(size.width, contentMaxWidth)

        // 핵심: 좌우 기본 패딩(화면마다 숫자 쓰지 않게 강제)
        let hPad = scaled(18)  // base 360에서 18 정도가 무난

        return AppMetrics(
            screenSize: size,
            scale: s,

            contentMaxWidth: maxW,
            horizontalPadding: hPad,

            space2: scaled(2),
            space4: scaled(4),
            space6: scaled(6),
            space8: scaled(8),
            space10: scaled(10),
            space12: scaled(12),
            space14: scaled(14),
            space16: scaled(16),
            space18: scaled(18),
            space20: scaled(20),
            space24: scaled(24),
            space28: scaled(28),
            space32: scaled(32),
            space44: scaled(44),

            radius12: scaled(12),
            radius16: scaled(16),
            radius18: scaled(18),
            radius24: scaled(24),
            radiusPill: scaled(999), // pill

            controlHeight44: 44,                 // 최소 터치영역은 고정
            controlHeight48: max(44, scaled(48)), // 제한적 스케일
            controlHeight52: max(44, scaled(52)),

            hairline: 1 / UIScreen.main.scale
        )
    }
}

// Environment 주입
private struct AppMetricsKey: EnvironmentKey {
    static let defaultValue: AppMetrics = .make(for: CGSize(width: 390, height: 844))
}

public extension EnvironmentValues {
    var appMetrics: AppMetrics {
        get { self[AppMetricsKey.self] }
        set { self[AppMetricsKey.self] = newValue }
    }
}
