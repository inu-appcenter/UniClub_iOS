//
//  AppTabBarChrome.swift
//  UniClub
//

import SwiftUI

/// ✅ "프레임 최하단(홈 인디케이터 영역 포함)"까지 깔리는 탭바 컨테이너
/// - overlay로만 붙여서 콘텐츠 레이아웃을 밀지 않습니다.
/// - Figma 기준(360x800) 탭바 높이 90을 baseWidth=360 스케일로 유지합니다.
/// - safeAreaInsets.bottom 만큼 아래를 추가로 채워서 "화면 끝"까지 연출합니다.
public struct AppTabBarChrome: View {
    @Environment(\.appMetrics) private var m
    @Binding private var selection: AppTab

    private let isHidden: Bool
    private let bottomInset: CGFloat

    // Figma: 360x800 프레임에서 탭바 90
    private var baseBarHeight: CGFloat { 90 * m.scale }
    private var totalHeight: CGFloat { baseBarHeight + bottomInset }

    public init(
        selection: Binding<AppTab>,
        isHidden: Bool,
        bottomInset: CGFloat
    ) {
        self._selection = selection
        self.isHidden = isHidden
        self.bottomInset = bottomInset
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ✅ 실제 탭 아이콘/라벨 영역 (safe area 위쪽)
            AppTabBar(selection: $selection)
                .frame(height: baseBarHeight)

            // ✅ 홈 인디케이터 영역(안전영역)까지 "비주얼"을 내려서 깔기
            Color.clear
                .frame(height: bottomInset)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
        .frame(height: totalHeight)
        .background(tabBarBackground)
        .overlay(
            Rectangle()
                .fill(AppColors.border)
                .frame(height: m.hairline),
            alignment: .top
        )
        // ✅ 숨김/표시 애니메이션
        .offset(y: isHidden ? (totalHeight + 10) : 0)
        .animation(.easeInOut(duration: 0.18), value: isHidden)
    }

    private var tabBarBackground: some View {
        ZStack(alignment: .top) {
            // ✅ "투명하지만 어두운" 블랙 그라데이션 (뒤 배경이 보이도록)
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.00), location: 0.00),
                    .init(color: Color.black.opacity(0.45), location: 0.35),
                    .init(color: Color.black.opacity(0.78), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // ✅ 상단 헤이즈(하이라이트)
            LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.50), location: 0.0),
                    .init(color: Color.white.opacity(0.18), location: 0.20),
                    .init(color: Color.white.opacity(0.00), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 70 * m.scale)
            .blur(radius: 10 * m.scale)
            .opacity(0.9)
            .allowsHitTesting(false)
        }
        // ✅ blur/gradient가 위로 번져서 전체 화면을 덮지 않게 "컨테이너"에서 클립
        .clipShape(Rectangle())
    }
}
