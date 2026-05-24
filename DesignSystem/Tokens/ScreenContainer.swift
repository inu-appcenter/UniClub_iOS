//
//  ScreenContainer.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

/// ScreenContainer의 상/하 여백을 화면 성격(시스템 네비바 vs 커스텀 헤더)에 맞춰 제어하기 위한 옵션입니다.
/// - 기본값(.default)은 기존 동작(상/하 m.space18)을 그대로 유지합니다.
public enum ScreenEdgePadding {
    case `default`
    case none
    case custom(CGFloat)

    fileprivate func value(using m: AppMetrics) -> CGFloat {
        switch self {
        case .default:
            return m.space18
        case .none:
            return 0
        case .custom(let v):
            return v
        }
    }
}

/// 좌우 패딩 모드. 표준 18pt(`.default`) 외에 피그마 사양상 다른 inset이 필요한 화면(예: Signup 31pt)을 위한 `.custom`.
public enum ScreenHorizontalPadding {
    case `default`
    case custom(CGFloat)

    fileprivate func value(using m: AppMetrics) -> CGFloat {
        switch self {
        case .default:
            return m.horizontalPadding
        case .custom(let v):
            return v
        }
    }
}

public struct ScreenContainer<Content: View>: View {
    @Environment(\.appMetrics) private var metrics

    private let scroll: Bool
    private let showsIndicators: Bool
    private let background: Color
    private let topPadding: ScreenEdgePadding
    private let bottomPadding: ScreenEdgePadding
    private let horizontalPadding: ScreenHorizontalPadding
    private let content: (AppMetrics) -> Content

    public init(
        scroll: Bool = false,
        showsIndicators: Bool = false,
        background: Color = AppColors.background,
        topPadding: ScreenEdgePadding = .default,
        bottomPadding: ScreenEdgePadding = .default,
        horizontalPadding: ScreenHorizontalPadding = .default,
        @ViewBuilder content: @escaping (AppMetrics) -> Content
    ) {
        self.scroll = scroll
        self.showsIndicators = showsIndicators
        self.background = background
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }

    public var body: some View {
        ZStack {
            background.ignoresSafeArea()

            Group {
                if scroll {
                    ScrollView(showsIndicators: showsIndicators) {
                        inner(metrics)
                    }
                } else {
                    inner(metrics)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func inner(_ m: AppMetrics) -> some View {
        content(m)
            .frame(maxWidth: m.contentMaxWidth, alignment: .topLeading)
            .padding(.horizontal, horizontalPadding.value(using: m))
            .padding(.top, topPadding.value(using: m))
            .padding(.bottom, bottomPadding.value(using: m))
            .keyboardAvoiding()
    }
}
