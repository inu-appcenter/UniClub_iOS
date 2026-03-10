//
//  ScrollDirectionObserver.swift
//  UniClub
//
//  Created by 제욱 on 2/7/26.
//

import SwiftUI

// MARK: - PreferenceKey for Scroll Offset
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ViewModifier
private struct ScrollDirectionObserver: ViewModifier {
    let coordinateSpaceName: String
    let threshold: CGFloat
    let onScrollDown: () -> Void
    let onScrollUp: () -> Void

    @State private var lastOffset: CGFloat = 0
    @State private var initialized: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    // ScrollView 안에서 컨텐츠의 minY를 읽어 스크롤 방향을 판단
                    let offset = proxy.frame(in: .named(coordinateSpaceName)).minY
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: offset)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { current in
                // 첫 값은 기준만 잡고 리턴 (초기 튐 방지)
                if !initialized {
                    initialized = true
                    lastOffset = current
                    return
                }

                let delta = current - lastOffset
                lastOffset = current

                // delta < 0 : 아래로 스크롤(컨텐츠가 위로 올라감) -> 탭바 숨김
                // delta > 0 : 위로 스크롤 -> 탭바 표시
                if delta < -threshold {
                    onScrollDown()
                } else if delta > threshold {
                    onScrollUp()
                }
            }
    }
}

extension View {
    /// ScrollView 콘텐츠에 붙이면 스크롤 방향(위/아래)을 콜백으로 전달
    func observeScrollDirection(
        in coordinateSpaceName: String,
        threshold: CGFloat = 6,
        onScrollDown: @escaping () -> Void,
        onScrollUp: @escaping () -> Void
    ) -> some View {
        modifier(
            ScrollDirectionObserver(
                coordinateSpaceName: coordinateSpaceName,
                threshold: threshold,
                onScrollDown: onScrollDown,
                onScrollUp: onScrollUp
            )
        )
    }
}
